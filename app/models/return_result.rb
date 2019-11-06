class ReturnResult < ActiveRecord::Base
  belongs_to :business
  belongs_to :unit
  belongs_to :query_result

  validates_presence_of :registration_no, :message => '不能为空'
  validates_uniqueness_of :registration_no, :message => '该挂号编号已存在'

  STATUS = { normal: 'normal', signed: 'signed', unit: 'unit', others: 'others', waiting: 'waiting'}

  STATUS_SHOW = { normal: '普通退件', signed: '签收后退件', others: '异常退件', waiting: '待查询'}

  
  def status_name
    status.blank? ? "" : ReturnResult::STATUS["#{status}".to_sym]
  end

  def self.get_result_with_status(response)
    response_signed = response.reject{|x| !x["opCode"].in? ["704", '748', '747', '703', '711']}

    last_result = response_signed.first
    last_result ||= {}

    if response_signed.size == 1
      status = ReturnResult::STATUS[:normal]
    elsif response_signed.size > 1
      status = ReturnResult::STATUS[:signed]
    else
      status = ReturnResult::STATUS[:others]
    end
    
    {"opt_at" => last_result["opTime"], "opt_desc" => last_result["opDesc"], "status" => status}
  end

  def self.select_years
    years = []
    i = 9
    until i < 0 
      years << Time.now.year-i
      i = i - 1
    end
    return years
  end

  def self.select_months
    ["1","2","3","4","5","6","7","8","9","10","11","12"]
  end
end
