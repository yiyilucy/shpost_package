class YwtbInterface
  @@ywtb_lock = Mutex.new
  
  def self.batch_init_ywtb
    businesses = I18n.t(:YwtbInterface)[:businesses]

    businesses.each do |x|
      business = Business.find_by no: x[:business_no]
      if x[:need_data_from_pkp]
        results = QueryResult.where(business: business, to_send: true, source: 'ESB').where.not(business_code: nil).order(order_date: :desc)
      else
        results = QueryResult.where(business: business, to_send: true).order(order_date: :desc)
      end
      if ! results.blank?
        batch_init_ywtb_interface_by_thread results, x[:ywtb_type]
        results.update_all(to_send: false)
      end
    end
  end

  def self.batch_init_ywtb_interface_by_thread(results, ywtb_type)
    # results_count = results.size
    i = results.size > 50 ? 50 : results.size
    ts = []
    i.times.each do |x|
      t = Thread.new do
        ActiveRecord::Base.transaction do
          begin
            while results.size > 0
              result = nil
              @@ywtb_lock.synchronize do
                result = results.pop
              end
              if result.blank?
                next
              end
              puts "#{ywtb_type} #{result.id}"
              YwtbInterface.ywtb_token result, ywtb_type
              # result.update! to_send: false
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

  def self.ywtb_token(result, ywtb_type = nil)
    body = {'clientId' => I18n.t(:YwtbInterface)[:oauth2_get_token][:client_id], 'clientSecret' => I18n.t(:YwtbInterface)[:oauth2_get_token][:client_secret]}.to_json
    InterfaceSender.interface_sender_initialize("ywtb_token", body, {business_id: result.business_id, unit_id: result.unit_id,  object_id: result.id, object_class: result.class.to_s, callback_params: {id: result.id, ywtb_type: ywtb_type}.to_json})
  end


  def self.ywtb_express(res, *args)
    ActiveRecord::Base.transaction do
      begin
        res_hash = ActiveSupport::JSON.decode(res)
        if !res_hash["access_token"].blank?
          result = QueryResult.find args.first['id']
          ywtb_type = args.first['ywtb_type']
          if ywtb_type.blank? || ywtb_type.eql?('rkb')
            body = self.init_ywtb_body_rkb res_hash["access_token"], result
          else
            body = self.init_ywtb_body_crj res_hash["access_token"], result
          end

          interface_sender = InterfaceSender.interface_sender_initialize("ywtb_express", body, {business_id: result.business_id, unit_id: result.unit_id,  object_id: result.id, object_class: result.class.to_s, callback_params: {id: result.id}.to_json})#, callback_params: {id: result.id, class: result.class.to_s}.to_json})
      
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
        result = QueryResult.find args.first['id']
        res_hash = ActiveSupport::JSON.decode(res)
        if res_hash['isSuccess']
          result.update! is_sent: true
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

  #人口办body
  def self.init_ywtb_body_rkb access_token, result
    body = {"accessToken"=> access_token,
              "departCode"=> "SHGASH",
              # "applyNo"=> result.qr_attr.try(:id_num),
              "applyNo"=> result.business_code,
              "expressType"=> "结果寄送",
              "applicant"=> result.qr_attr.try(:name),
              "senderName"=> result.qr_attr.try(:name),
              "senderAddress"=> result.qr_attr.try(:address),
              "senderAddressP"=> result.qr_attr.try(:province),
              "senderAddressC"=> result.qr_attr.try(:city),
              "senderAddressD"=> result.qr_attr.try(:district),
              "senderPostcode"=> '200000',
              "senderPhone"=> result.qr_attr.try(:phone),
              "recieverName"=> "人口办",
              "recieverAddress"=> "康定路460弄8号",
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
              "isSend" => result.status.in?(QueryResult::STATUS_DELIVERED) ? "是" : "否",
              "sendTime" => result.status.in?(QueryResult::STATUS_DELIVERED) ? result.operated_at.try(:strftime,'%Y-%m-%d %H:%M:%S'): '' ,
              "isTips"=> "是"
              }.to_json
  end

  #出入境body
  def self.init_ywtb_body_crj access_token, result
    body = {"accessToken"=> access_token,
              "departCode"=> "SHGASH",
              "applyNo"=> result.business_code,
              "expressType"=> "结果寄送",
              "applicant"=> result.qr_attr.try(:name),
              "senderName"=> result.qr_attr.try(:name),
              "senderAddress"=> result.qr_attr.try(:address),
              "senderAddressP"=> result.qr_attr.try(:province),
              "senderAddressC"=> result.qr_attr.try(:city),
              "senderAddressD"=> result.qr_attr.try(:district),
              "senderPostcode"=> '200000',
              "senderPhone"=> result.qr_attr.try(:phone),
              "recieverName"=> "出入境",
              "recieverAddress"=> "民生路1500号",
              "recieverAddressP"=> "上海",
              "recieverAddressC"=> "上海",
              "recieverAddressD"=> "上海",
              "recieverPostcode"=> "200000",
              "recieverPhone"=> "021-52997350",
              "orderNo"=>  result.business_code,
              "expressNo"=> result.registration_no,
              "itemName"=> "关于出入境事项的申请审批",
              "fee"=> "0",
              "feePay"=> "申请人",
              "feePayMethod"=> "货到付款",
              "serviceType"=> "标准快递",
              "expressArea"=> "上海同城、外地",
              "expressCompany"=> "EMS",
              "createTime"=> result.qr_attr.try(:batch_date).try(:strftime,'%Y-%m-%d %H:%M:%S'),
              "createMethod"=> "线下下单",
              "isSend" => result.status.in?(QueryResult::STATUS_DELIVERED) ? "是" : "否",
              "sendTime" => result.status.in?(QueryResult::STATUS_DELIVERED) ? result.operated_at.try(:strftime,'%Y-%m-%d %H:%M:%S'): '' ,
              "isTips"=> "否"
              }.to_json
  end
end