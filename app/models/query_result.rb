class QueryResult < ActiveRecord::Base
	belongs_to :business
	belongs_to :unit

	validates_presence_of :registration_no, :message => '不能为空'
    validates_uniqueness_of :registration_no, :message => '该挂号编号已存在'
end
