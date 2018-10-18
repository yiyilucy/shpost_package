class ImportFile < ActiveRecord::Base
	belongs_to :business
	belongs_to :unit
	belongs_to :user

	STATUS = { success: '成功', fail: '失败', waiting: '待处理', doing: '处理中'}
	
    def status_name
	  status.blank? ? "" : ImportFile::STATUS["#{status}".to_sym]
	end

end
