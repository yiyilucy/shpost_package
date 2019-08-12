class InterfaceInfo < ActiveRecord::Base
  belongs_to :unit
  belongs_to :business
  belongs_to :parent, polymorphic: true
  STATUS = {success: 'success', failed: 'failed'}
  # STATUS_NAME = { success: '成功', failed: '失败' }

  def self.log(controller, action, unit, business, status, request, params, response, ip, business_code, object = nil)
    interface_info = InterfaceInfo.find_by(controller_name: controller, action_name: action, unit: unit, business: business, status: 'failed', business_code: business_code) if (! status && ! business_code.blank?)
    if interface_info.blank?
      interface_info = InterfaceInfo.create!(controller_name: controller, action_name: action, unit: unit, business: business, status: (status ? STATUS[:success] : STATUS[:failed]), request_body: request, params: params, response_body: response, request_ip: ip,business_code: business_code, parent: object)
    else
      interface_info.update!(request_body: request, params: params, response_body: response, request_ip: ip, parent: object)
    end
  end
end
