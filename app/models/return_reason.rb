class ReturnReason < ActiveRecord::Base
	belongs_to :unit
	validates_presence_of :reason
end
