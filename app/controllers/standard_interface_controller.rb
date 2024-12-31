class StandardInterfaceController < ApplicationController
  skip_before_filter :authenticate_user!
  # before_action :verify_params
  # before_action :verify_sign
  around_action :interface_return
  skip_before_filter :verify_authenticity_token 
  #load_and_authorize_resource

  def mail_push
    return error_builder('0005', '邮件号为空') if @context_hash['MAIL_NO'].blank?
    mail_no = @context_hash['MAIL_NO']
  
    @business_code = @context_hash['BUSINESS_CODE']
    begin
      mail = StandardInterface.mail_push(@context_hash, @business, @unit)
    rescue Exception => e
      if ! e.is_a? RuntimeError
        out_error e
      end
      error_builder('0005', e.message)
      return
    end
    if !mail.blank? && mail.is_a?(QueryResult)
      @object = mail
      return success_builder
    else
      return error_builder('9999')
    end
  end

  def mail_query
    return error_builder('0005', '查询列表为空') if @context_hash['MAIL_NO'].blank?
    begin
      success_builder(StandardInterface.mail_query(@context_hash, @business, @unit))
    rescue Exception => e
      if ! e.is_a? RuntimeError
        out_error e
      end
      error_builder('0005', e.message)
      return
    end
  end

  def mail_query_in_time
    return error_builder('0005', '查询列表为空') if @context_hash['MAIL_NO'].blank?
    
    @business_code = @context_hash['MAIL_NO']

    begin
      success_builder(StandardInterface.mail_query_in_time(@context_hash, @business, @unit))
    rescue Exception => e
      if ! e.is_a? RuntimeError
        out_error e
      end
      error_builder('0005', e.message)
      return
    end
  end

  def mail_query_in_local
    return error_builder('0005', '查询列表为空') if @context_hash['MAIL_NO'].blank?
    
    @business_code = @context_hash['MAIL_NO']

    begin
      success_builder(StandardInterface.mail_query_in_local(@context_hash, @business, @unit))
    rescue Exception => e
      if ! e.is_a? RuntimeError
        out_error e
      end
      error_builder('0005', e.message)
      return
    end
  end

  def waybill_query_in_local
    mail_no = params[:mail_no]
    return error_builder('0005', '查询列表为空') if mail_no.blank?
    
    @business_code = mail_no

    # @unit = Unit.first
    # @business = Business.first

    begin
      success_builder(StandardInterface.waybill_query_in_local(mail_no))
    rescue Exception => e
      if ! e.is_a? RuntimeError
        out_error e
      end
      error_builder('0005', e.message)
      return
    end
  end

  def phone_query
    mail_no = params[:mail_no]
    return error_builder('0005', '查询列表为空') if mail_no.blank?
    
    @business_code = mail_no

    # @unit = Unit.first
    # @business = Business.first

    begin
      success_builder(StandardInterface.phone_query(mail_no))
    rescue Exception => e
      if ! e.is_a? RuntimeError
        out_error e
      end
      error_builder('0005', e.message)
      return
    end
  end

  private
  def out_error e
    puts e.message
    puts e.backtrace 
    Rails.logger.error("#{e.class.name} #{e.message}")
    e.backtrace.each{|x| Rails.logger.error(x)}
  end

  def verify_params
    @format = params[:format]
    return error_builder('0002') if !@format.eql? 'JSON'

    @unit = Unit.find_by(no: params[:unit])
    return error_builder('0003') if @unit.nil?

    @business = Business.find_by(no: params[:business], unit: @unit)
    return error_builder('0004') if @business.nil?

    @context = params[:context]
    begin
      @context_hash = ActiveSupport::JSON.decode(@context)
    rescue Exception => e
      return error_builder('0002')
    end

    @mark = params[:mark]
    
    return verify_sign

  end

  def verify_sign
    @sign = params[:sign]
    secrect_key = @business.secret_key1 ||= @business.secret_key
    
    return error_builder('0001') if !@sign.eql? Base64.strict_encode64(Digest::MD5.hexdigest("#{@context}#{secrect_key}"))
  end

  def interface_return
    begin
      verify_params if ! params[:action].eql? "waybill_query_in_local"
      if !@status.eql? false
        yield
      end
    ensure
      # InterfaceInfo.log(params[:controller], params[:action], @unit, @business, @status, request.url, params.to_json, @return_json.to_json, request.ip, @business_code, @object) unless params[:action].eql?('mail_query')
    end
  end

  def success_builder(info = nil)
    @status = true
    success = {'FLAG' => 'success'}
    if info.nil?
      @return_json = success
    else
      @return_json = success.merge info
    end
    render json: @return_json
  end

  def error_builder(code, msg = nil)
    @status = false
    @return_json = {'FLAG' => 'failure', 'CODE' => code, 'MSG' => msg.nil? ? I18n.t("standard_interface.error.#{code}") : I18n.t("standard_interface.error.#{code}") + ':' + msg }.to_json
    # @return_json
    Rails.logger.error("#{code} #{msg}")

    render json: @return_json
  end

  def render_json
    render json: @return_json
  end

end
