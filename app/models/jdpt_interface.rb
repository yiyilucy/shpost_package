class JdptInterface
  def self.jdpt_trace(query_result)

    body = JdptInterface.init_jdpt_trace_body(query_result)

    InterfaceSender.interface_sender_initialize("jdpt_trace", body, {business_id: query_result.business_id, unit_id: query_result.unit_id,  object_id: query_result.id, object_class: query_result.class.to_s})
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

  def do_response(res, *args)
    begin
      # res_hash = ActiveSupport::JSON.decode(res)
      # msg_body = res_hash['msgBody']
      # msg = JSON.parse msg_body
      puts res

      return true
    rescue => e
      return false
    end
  end

  def self.data_digest(context, secret_key)
    Base64.encode64(Digest::MD5.hexdigest("#{context}#{secret_key}")).strip
  end
end