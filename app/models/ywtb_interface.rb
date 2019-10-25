class YwtbInterface
  @@ywtb_lock = Mutex.new
  
  def self.batch_init_ywtb
    business = Business.find_by no: I18n.t(:YwtbInterface)[:business][:no]
    results = QueryResult.where(business: business, to_send: true).order(order_date: :desc)
    batch_init_ywtb_interface_by_thread results

    results.update_all(to_send: false)
  end

  def self.batch_init_ywtb_interface_by_thread(results)
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
              YwtbInterface.ywtb_token result
            end
          rescue Exception => e
            Rails.logger.error e.message
            puts e.message
            throw e
          end
        end
      end
      ts << t
    end
    ts.each do |x|
      x.join
    end
  end

  def self.ywtb_token(result)
    body = {'clientId' => I18n.t(:YwtbInterface)[:oauth2_get_token][:client_id], 'clientSecret' => I18n.t(:YwtbInterface)[:oauth2_get_token][:client_secret]}.to_json
    InterfaceSender.interface_sender_initialize("ywtb_token", body, {business_id: result.business_id, unit_id: result.unit_id,  object_id: result.id, object_class: result.class.to_s, callback_params: {id: result.id}.to_json})
  end

  def self.ywtb_express(res, *args)
    ActiveRecord::Base.transaction do
      begin
        res_hash = ActiveSupport::JSON.decode(res)
        if !res_hash["access_token"].blank?
          result = QueryResult.find args.first['id']
          body = {"accessToken"=> res_hash["access_token"],
            "orgCode"=> "SHGASH",
            "applyNo"=> result.qr_attr.try(:id_num),
            "expressType"=> "结果寄送",
            "applicant"=> result.qr_attr.try(:name),
            "senderName"=> result.qr_attr.try(:name),
            "senderAddress"=> result.qr_attr.try(:address),
            "senderAddressP"=> result.qr_attr.try(:province),
            "senderAddressC"=> result.qr_attr.try(:city),
            "senderAddressD"=> result.qr_attr.try(:district),
            "senderPostcode"=> result.postcode,
            "senderPhone"=> result.qr_attr.try(:phone),
            "recieverName"=> "人口办",
            "recieverAddress"=> "人口办",
            "recieverAddressP"=> "上海",
            "recieverAddressC"=> "上海",
            "recieverAddressD"=> "黄浦区",
            "recieverPostcode"=> "200000",
            "recieverPhone"=> "021-52997350",
            "orderNo"=> result.registration_no,
            "expressNo"=> result.registration_no,
            "itemName"=> "身份证件签发",
            "fee"=> "0",
            "feePay"=> "申请人",
            "feePayMethod"=> "货到付款",
            "serviceType"=> "标准快递",
            "expressArea"=> "上海同城",
            "expressCompany"=> "EMS",
            "createTime"=> result.qr_attr.try(:batch_date).try(:strftime,'%Y-%m-%d %H:%M:%S'),
            "createMethod"=> "线下下单",
            "isSend"=> result.status.in?(QueryResult::STATUS_DELIVERED) ? "是" : "否",
            "isTips"=> "是"
            }.to_json

          interface_sender = InterfaceSender.interface_sender_initialize("ywtb_express", body, {business_id: result.business_id, unit_id: result.unit_id,  object_id: result.id, object_class: result.class.to_s})#, callback_params: {id: result.id, class: result.class.to_s}.to_json})
      
          interface_sender.interface_send
          return true
        else
          return false
        end
      rescue => e
        Rails.logger.error e.message
        puts e.message
        throw e
      end
    end
    return false
    # if ! InterfaceSender.where(object_id: result.id, status:InterfaceSender::STATUS[:waiting]).exists?

    #   body = JdptInterface.init_jdpt_trace_body(result)

    #   InterfaceSender.interface_sender_initialize("jdpt_trace", body, {business_id: result.business_id, unit_id: result.unit_id,  object_id: result.id, object_class: result.class.to_s, callback_params: {id: result.id, class: result.class.to_s}.to_json})
    # end
  end

  def self.do_response(res, *args)
    ActiveRecord::Base.transaction do
      begin
        res_hash = ActiveSupport::JSON.decode(res)
        if res_hash['isSuccess']
          return true
        else
          return false
        end
      rescue => e
        Rails.logger.error e.message
        puts e.message
        throw e
      end
    end
    return false
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
end