class MailTrace < PkpDataRecord
  has_many :mail_trace_details

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