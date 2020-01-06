class QueryResult < ActiveRecord::Base
	belongs_to :business
	belongs_to :unit
  has_one :qr_attr, dependent: :destroy
  has_one :return_result

	validates_presence_of :registration_no, :message => '不能为空'
  validates_uniqueness_of :registration_no, :message => '该挂号编号已存在'

  STATUS = { own: 'own', other: 'other', unit: 'unit', returns: 'returns', waiting: 'waiting'}

  STATUS_SHOW = { own: '本人收', other: '他人收', unit: '单位收', returns: '退件', waiting: '未妥投'}

  STATUS_DELIVERED = [STATUS[:own], STATUS[:other], STATUS[:unit]]

  def status_name
  	status.blank? ? "" : QueryResult::STATUS_SHOW["#{status}".to_sym]
	end

  def update_to_send
    if to_send?
      update! to_send: true
    end
  end

  def to_send?
    businesses = I18n.t(:YwtbInterface)[:businesses].map{|x| x[:business_no]}
    if business.no.in?(businesses)
      if !status.eql?(STATUS[:waiting]) || ! is_sent || order_date <= (Date.today - business.end_date)
        return true
      end 
    end
    return false
  end

  def self.get_result_with_status(response)
    last_result = response.last

    opt_code = last_result["opCode"]
    opt_desc = last_result["opDesc"]
    opt_time = last_result["opTime"]
    
    status = QueryResult::STATUS[:waiting]

    if !opt_code.blank?
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
      elsif !response.reject{|x| !x["opCode"].in? ["708", '711']}.blank?
        status = QueryResult::STATUS[:returns]
      end
    end
    result = {"opt_at" => opt_time, "opt_desc" => opt_desc, "status" => status}

    # if status.eql? QueryResult::STATUS[:waiting]
      result["is_posting"] = response.find{|x| x['opCode'].eql? '203' }.blank? ? false : true
    # else
      # result["is_posting"] = false
    # end

    result
  end
  
end


