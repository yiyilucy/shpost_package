class MailTraceHis < PkpDataRecordHis
  self.table_name = 'mail_traces_2025'
  self.primary_key = 'id' 

  has_many :mail_trace_his_details, foreign_key: 'mail_trace_id'

  STATUS = { own: 'own', other: 'other', unit: 'unit', returns: 'returns', waiting: 'waiting', del: 'del'}

  STATUS_SHOW = { own: '本人收', other: '他人收', unit: '单位收', returns: '退件', waiting: '未妥投', del: '删除'}

  STATUS_DELIVERED = [STATUS[:own], STATUS[:other], STATUS[:unit]]
  
  def jdpt_traces
    trace = [] 
    self.mail_trace_details.order(:created_at).each do |x|
      if !x.blank?
        trace += JSON.parse(x.traces.gsub("=>", ":"))
      end
    end

    msg = {"responseState" => true,"errorDesc" => "","receiveID" => "", "responseItems" => trace}
  end
end