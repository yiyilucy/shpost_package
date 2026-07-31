class SwInterfaceController < ApplicationController
  skip_before_filter :authenticate_user!
  # before_action :verify_params
  # before_action :verify_sign
  around_action :interface_return
  skip_before_filter :verify_authenticity_token

  def order_enter
    return error_builder('纳税人名称为空') if @context_hash['NSRMC'].blank?
    return error_builder('领票人名称为空') if @context_hash['LPRXM'].blank?
    return error_builder('领票人证件号为空') if @context_hash['LPRZJHM'].blank?
    return error_builder('配送地址为空') if @context_hash['DZ'].blank?
    return error_builder('明细信息为空') if @context_hash['MXXX'].blank?
   

    @json_hash = {'ORDER_ID' => @context_hash['SQDBH'], 'PROPOSER' => @context_hash['NSRMC'], 'CUST_NAME' => @context_hash['LPRXM'], 'ID_CARD' => @context_hash['LPRZJHM'], 'MOBILE' => @context_hash['LPRLXDH'], 'BAK_NAME' => @context_hash['LPRXMB'], 'BAK_ID_CARD' => @context_hash['LPRZJHMB'], 'BAK_MOBILE' => @context_hash['LPRLXDHB'], 'ADDR' => @context_hash['DZ'], 'PAY_TYPE' => @context_hash['PAYMENT_TYPE']}

    order_details = []

    @context_hash['MXXX'].each do |x|
      order_detail = {'BUSINESS_SKU' => x['FPZLDM'], 'NAME' => x['FPZLMC'], 'BILL_CODE' => x['FPDM'], 'START_NUMBER' => x['FPQSHM'], 'END_NUMBER' => x['FPZZHM'], 'QTY' => x['BS']}
      order_details << order_detail
    end
    
    @json_hash['ORDER_DETAILS'] = order_details

    begin
      order = StandardInterface.order_enter(@json_hash, @business, @unit, @storage)
    rescue => e
      if ! e.is_a? RuntimeError
        out_error e
      end
      error_builder(e.message)
      return
    end

    if !order.blank?
      if order.is_a? Order
        @object = order
        return success_builder({'SQDBH' => order.business_order_id})
      else
        return error_builder('创建失败')
      end
    else
      return error_builder('创建失败')
    end
  end

  def ygjg_query
    return error_builder('明细信息为空') if @context_hash['MXXX'].blank?

    weight = 0

    @context_hash['MXXX'].each do |x|
      amount = x['BS'].to_i
      return  error_builder("#{x['FPZLDM']}的发票份数不正确: #{amount}") if (amount.blank? || amount.to_i <= 0)

      tax_price = TaxPrice.find_by(tax_code: x['FPZLDM'])
      
      return error_builder("不存在该发票种类: #{x['FPZLDM']}") if tax_price.blank?
      
      weight += tax_price.get_weight_by_amount(amount)
    end
    price = TaxPrice.get_price_by_weight(weight.to_i)
    success_builder({'YGJG' => price})
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
    return error_builder('format格式错误') if !@format.eql? 'JSON'

    # @unit = Unit.find_by(no: params[:unit])
    # return error_builder('0004') if @unit.nil?

    # @business = Business.find_by(no: params[:business], unit: @unit)
    # return error_builder('0003') if @business.nil?

    # @storage = Storage.find_by(no: params[:storage], unit: @unit)

    # @storage ||= @unit.default_storage


    @context = params[:json_param]
    return error_builder('json_param参数为空') if @context.blank?
    if @context.is_a?(String) || !@context.to_hash.class.eql?(Hash)
      begin
        # binding.pry
        @context_hash = ActiveSupport::JSON.decode(@context)
      rescue => e
        return error_builder('JSON格式错误')
      end
    else
      @context_hash = @context
    end
    # binding.pry
    return verify_context if ! params['action'].eql? 'ygjg_query'
  end

  def verify_context
    return error_builder('税务文书号为空') if @context_hash['SQDBH'].blank?

    @business_order_id = @context_hash['SQDBH']

    return error_builder('核算机关代码错误') if @context_hash['HSJGDM'].blank? || Business.find_by_id(I18n.t("sw_interface.business.#{@context_hash['HSJGDM']}")).blank?

    @business = Business.find_by_id I18n.t("sw_interface.business.#{@context_hash['HSJGDM']}")

    return error_builder('发票仓库代码错误') if  @context_hash['FPKFDM'].blank? || Storage.find_by_id(I18n.t("sw_interface.storage.#{@context_hash['FPKFDM']}")).blank?

    @storage = Storage.find_by_id I18n.t("sw_interface.storage.#{@context_hash['FPKFDM']}")

    return error_builder('仓库与机关不匹配') if !@business.unit.eql? @storage.unit

    @unit = @storage.unit
  end

  def interface_return
    begin
      verify_params
      if !@status.eql? false
        yield
      end
    ensure
      InterfaceInfo.log(params[:action], @unit, @storage, @business, @status, request.url, params.to_json, @return_json.to_json, request.ip, @business_order_id, @object) if ! params['action'].eql? 'ygjg_query'
    end
  end

  def success_builder(info = nil)
    @status = true
    success = {'FLAG' => '1'}
    if info.nil?
      @return_json = success
    else
      @return_json = success.merge info
    end
    # @return_json
    render json: @return_json
  end

  def error_builder(msg = nil)
    @status = false
    @return_json = {'FLAG' => '0', 'SQDBH' => @business_order_id,'MSG' => msg }.to_json
    # @return_json
    Rails.logger.error("#{msg}")

    render json: @return_json
  end

  # def error_builder_without_render(code, msg = nil)
  # @status = false
  # @return_json = {'FLAG' => 'failure', 'CODE' => code, 'MSG' => msg.nil? ? I18n.t("standard_interface.error.#{code}") : I18n.t("standard_interface.error.#{code}") + ':' + msg }.to_json
  # end

  def render_json
    render json: @return_json
  end
 
end
