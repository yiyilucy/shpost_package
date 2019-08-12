class JdptInterface

  def self.clean_date_by_days(days = 90)
    date = (Time.now - days.day).to_date
    QueryResult.where("created_at < ?", date).delete_all
    ReturnResult.where("created_at < ?", date).delete_all
    InterfaceSender.where("created_at < ?", date).delete_all
  end

  @@jdpt_lock = Mutex.new
  def self.batch_init_jdpt_trace
    Business.all.each do |business|
      query_results = get_query_results business

      return_results = get_return_results business

      batch_init_jdpt_trace_by_thread query_results

      batch_init_jdpt_trace_by_thread return_results
    end
  end

  def self.batch_init_jdpt_trace_by_thread(results)
    i = results.size > 50 ? 50 : results.size
    ts = []
    i.times.each do |x|
      t = Thread.new do
        ActiveRecord::Base.transaction do
          begin
            while results.size > 0
              result = nil
              @@jdpt_lock.synchronize do
                result = results.pop
              end
              if result.blank?
                next
              end
              JdptInterface.jdpt_trace result
            end
          rescue Exception => e
            Rails.logger.error e.message
            puts e.message
            raise ActiveRecord::Rollback
          end
        end
      end
      ts << t
    end
    ts.each do |x|
      x.join
    end
  end

  def self.get_query_results(business)
    query_results = QueryResult.where(status: QueryResult::STATUS[:waiting]).where(business: business)
    if ! business.end_date.blank? && business.end_date.to_i > 0 && business.end_date.to_i > business.start_date.to_i
      start_date = Date.today - business.end_date.to_i.days
      query_results = query_results.where("order_date >= ?", start_date)
    end

    if ! business.start_date.blank? && business.start_date.to_i > 0
      end_date = Date.today - business.start_date.to_i.days
      query_results = query_results.where("order_date < ?", end_date) 
    end

    query_results = query_results.order(order_date: :desc)
  end

  def self.get_return_results(business)
    ReturnResult.where(status: ReturnResult::STATUS[:waiting]).where(business: business).order(order_date: :desc)
  end

  def self.jdpt_trace(result)
    if ! InterfaceSender.where(object_id: result.id, status:InterfaceSender::STATUS[:waiting]).exists?

      body = JdptInterface.init_jdpt_trace_body(result)

      InterfaceSender.interface_sender_initialize("jdpt_trace", body, {business_id: result.business_id, unit_id: result.unit_id,  object_id: result.id, object_class: result.class.to_s, callback_params: {id: result.id, class: result.class.to_s}.to_json})
    end
  end

  def self.init_jdpt_trace_body(result)
    business = result.business
    body = {}
    body['sendID'] = send_id = business.send_id
    body['sendID'] = send_id ||= 'SHPOST_PACKAGE'
    body['proviceNo'] = '99'
    body['msgKind'] = 'SHPOST_PACKAGE_JDPT_TRACE'
    body['serialNo'] = "#{result.id}_#{Time.now.to_f}"
    body['sendDate'] = Time.now.strftime('%Y%m%d%H%M%S')
    body['receiveID'] = 'JDPT'
    # body['batchNo'] = 
    body['dataType'] = 1

    msg_body = {'traceNo' => result.registration_no}.to_json
    # body['msgBody'] = "URLENCODE(#{msg_body})"
    body['msgBody'] = URI.encode(msg_body)
    body['dataDigest'] = self.data_digest(msg_body, business.secret_key)

    return body.to_json
  end

  def self.do_response(res, *args)
    ActiveRecord::Base.transaction do
      begin
        res_hash = ActiveSupport::JSON.decode(res)
        if res_hash["responseState"]
          if args.first['class'].blank?
            result_class = QueryResult
          else
            result_class = eval(args.first['class'])
          end

          result = result_class.find args.first['id']
          if result.blank?
            return false
          end

          if ! res_hash["errorDesc"].blank? && res_hash["responseItems"].blank?
            result.update!(status: result_class::STATUS[:waiting], result: res_hash["errorDesc"], query_date: Date.today.to_time, is_posting: false)
            return true
          end
          last_result = result_class.get_result_with_status(res_hash["responseItems"])
          
          if result.is_a? QueryResult
            result.update!(status: last_result["status"], result: last_result["opt_desc"], query_date: Date.today.to_time, operated_at: last_result["opt_at"], is_posting: last_result["is_posting"])
          else
            result.update!(status: last_result["status"], result: last_result["opt_desc"], query_date: Date.today.to_time, operated_at: last_result["opt_at"])
          end
          return true
        else
          return false
        end
      rescue => e
        raise ActiveRecord::Rollback
      end
    end
    return false
  end

  def self.data_digest(context, secret_key)
    Base64.encode64(Digest::MD5.hexdigest("#{context}#{secret_key}")).strip
  end
end