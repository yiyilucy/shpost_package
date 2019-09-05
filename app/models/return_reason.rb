class ReturnReason < ActiveRecord::Base
	belongs_to :unit
	validates_presence_of :reason

	def self.reason_select_options(unit_id)
		options = []
		i=1

		ReturnReason.where(unit_id: unit_id).order(:created_at).each do |x|
			options << [i.to_s+"."+x.reason, x.id]
			i += 1
		end
		return options
	end
end
