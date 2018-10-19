class JdptInterface

  @@jdpt_lock = Mutex.new
  def self.batch_init_jdpt_trace
    Business.all.each do |business|
      end_date = Time.now - business.start_date.to_i.days
      
      query_results = QueryResult.where(status: QueryResult::STATUS[:waiting]).where(business: business)
      if ! business.end_date.blank? && business.end_date.to_i > 0 && business.end_date.to_i > business.start_date.to_i
        start_date = Time.now - business.end_date.to_i.days
        query_results = query_results.where("order_date >= ?", start_date)
      end

      if ! business.start_date.blank? && business.start_date.to_i > 0
        end_date = Time.now - business.start_date.to_i.days
        query_results = query_results.where("order_date < ?", end_date) 
      end

      query_results = query_results.order(:order_date)

      i = query_results.size > 10 ? 10 : query_results.size
      ts = []
      i.times.each do |x|
        t = Thread.new do
          ActiveRecord::Base.transaction do
            begin
              while query_results.size > 0
                query_result = nil
                @@jdpt_lock.synchronize do
                  query_result = query_results.pop
                end
                JdptInterface.jdpt_trace query_result
              end
            rescue Exception => e
              Rails.logger.error e.message
              raise ActiveRecord::Rollback
            end
          end
        end
        ts << t
      end
      ts.each do |x|
        x.join
      end

          # query_results.each do |x|
          #   JdptInterface.jdpt_trace x
          # end
    end
  end

  def self.jdpt_trace(query_result)

    body = JdptInterface.init_jdpt_trace_body(query_result)

    InterfaceSender.interface_sender_initialize("jdpt_trace", body, {business_id: query_result.business_id, unit_id: query_result.unit_id,  object_id: query_result.id, object_class: query_result.class.to_s, callback_params: {id: query_result.id}.to_json})
  end

  def self.init_jdpt_trace_body(query_result)
    business = query_result.business
    body = {}
    body['sendID'] = send_id = 'SHPOST_PACKAGE'
    body['proviceNo'] = '99'
    body['msgKind'] = 'SHPOST_PACKAGE_JDPT_TRACE'
    body['serialNo'] = "#{query_result.id}_#{Time.now.to_f}"
    body['sendDate'] = Time.now.strftime('%Y%m%d%H%M%S')
    body['receiveID'] = 'JDPT'
    # body['batchNo'] = 
    body['dataType'] = 1

    msg_body = {'traceNo' => query_result.registration_no}.to_json
    # body['msgBody'] = "URLENCODE(#{msg_body})"
    body['msgBody'] = URI.encode(msg_body)
    body['dataDigest'] = self.data_digest(msg_body, business.secret_key)

    return body.to_json
  end

  def self.do_response(res, *args)
    begin
      res_hash = ActiveSupport::JSON.decode(res)
      if res_hash["responseState"]
        query_result = QueryResult.find args.first['id']
        if query_result.blank?
          return false
        end

        last_result = res_hash["responseItems"].last

        status = nil
        opt_code = last_result["opCode"]
        if opt_code.blank?
          return false
        end

        if opt_code.eql? '704'
          if last_result["opDesc"].include? '本人'
            status = QueryResult::STATUS[:own]
          elsif last_result["opDesc"].include? '他人'
            status = QueryResult::STATUS[:other]
          else
            status = QueryResult::STATUS[:unit]
          end
        elsif opt_code.eql? '748'
          status = QueryResult::STATUS[:own]
        elsif opt_code.eql? '747'
          status = QueryResult::STATUS[:unit]
        elsif opt_code.in? ['708', '711']
          status = QueryResult::STATUS[:returns]
        end
        query_result.update(status: status, result: last_result["opDesc"], query_date: Date.today.to_time)
        return true
      else
        return false
      end
    rescue => e
      return false
    end
  end

  def self.data_digest(context, secret_key)
    Base64.encode64(Digest::MD5.hexdigest("#{context}#{secret_key}")).strip
  end
end