class QueryResult < ActiveRecord::Base
	belongs_to :business
	belongs_to :unit

	validates_presence_of :registration_no, :message => '不能为空'
  validates_uniqueness_of :registration_no, :message => '该挂号编号已存在'

  STATUS = { own: 'own', other: 'other', unit: 'unit', returns: 'returns', waiting: 'waiting'}

  STATUS_SHOW = { own: '本人收', other: '他人收', unit: '单位收', returns: '退件', waiting: '未妥投'}

  def status_name
  	status.blank? ? "" : QueryResult::STATUS["#{status}".to_sym]
	end

  def self.get_result_with_status(response)
    last_result = response.last

    opt_code = last_result["opCode"]
    opt_desc = last_result["opDesc"]
    
    if opt_code.blank?
      return false
    end
    status = QueryResult::STATUS[:waiting]

    if opt_code.eql? '704'
      if opt_desc.include? '本人'
        status = QueryResult::STATUS[:own]
      elsif opt_desc.include? '他人'
        status = QueryResult::STATUS[:other]
      else
        status = QueryResult::STATUS[:unit]
      end
    elsif opt_code.eql? '748'
      status = QueryResult::STATUS[:own]
    elsif opt_code.eql? '747'
      status = QueryResult::STATUS[:unit]
    elsif opt_code.in? ['708', '711']
      status = QueryResult::STATUS[:returns]
    end
    {"opt_at" => last_result["optTime"], "opt_desc" => opt_desc, "status" => status}
  end

 	

  
end