class QueryResult < ActiveRecord::Base
	belongs_to :business
	belongs_to :unit

	validates_presence_of :registration_no, :message => '不能为空'
    validates_uniqueness_of :registration_no, :message => '该挂号编号已存在'

    STATUS = { own: '本人收', other: '他人收', unit: '单位收', returns: '退件', waiting: '未妥投'}

    def status_name
	  status.blank? ? "" : QueryResult::STATUS["#{status}".to_sym]
	end


end
