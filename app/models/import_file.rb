class ImportFile < ActiveRecord::Base
	belongs_to :business
	belongs_to :unit
	belongs_to :user

	STATUS = { success: '成功', fail: '失败', waiting: '待处理'}
	IS_PROCESS = { true: '是', false: '否'}

    def status_name
	  status.blank? ? "" : ImportFile::STATUS["#{status}".to_sym]
	end

	def is_process_name
	  if is_process
	    name = "是"
	  else
	    name = "否"
	  end
	end

end
