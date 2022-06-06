class QueryResult < ActiveRecord::Base
	belongs_to :business
	belongs_to :unit
  has_one :qr_attr, dependent: :destroy
  has_one :return_result
  has_one :pkp_waybill_base_local, dependent: :destroy
  has_many :query_result_import_files

	validates_presence_of :registration_no, :message => '不能为空'
  validates_uniqueness_of :registration_no, :message => '该挂号编号已存在'

  STATUS = { own: 'own', other: 'other', unit: 'unit', returns: 'returns', waiting: 'waiting', cancel: 'cancel'}

  STATUS_SHOW = { own: '本人收', other: '他人收', unit: '单位收', returns: '退件', waiting: '未妥投', cancel: '取消'}

  STATUS_DELIVERED = [STATUS[:own], STATUS[:other], STATUS[:unit]]

  # DOWNLOAD_DIRECT = "#{Rails.root}/public/download/"

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

  def self.export_results
    start_date = Date.today-1.days
    end_date = Date.today
    export_results_by_date(start_date, end_date)
  end

  def self.export_results_by_date(start_date, end_date)
    filename = "cupd-receive-#{Time.now.strftime('%Y%m%d')}-EMS.csv"
    # file_path = QueryResult::DOWNLOAD_DIRECT + filename  
    file_path = I18n.t("schedule_export_file_path") + filename 

    results = QueryResult.includes(:qr_attr).includes(:business).where("operated_at >= ? and operated_at < ? and status in (?) and businesses.no = ?", start_date, end_date, QueryResult::STATUS_DELIVERED, I18n.t(:YL)[:businesses][0][:business_no])
    exportresults_xls_content_for(results, file_path)
  end
  
  def self.exportresults_xls_content_for(results, file_path)
    # xls_report = StringIO.new   #temp
    book = Spreadsheet::Workbook.new   
    sheet = book.create_worksheet :name => "Results"  

    title = Spreadsheet::Format.new :color => :black, :weight => :bold, :size => 10  
    sheet.row(0).default_format = title 
    sheet.row(0).concat %w{serial registNbr name mobile state date receiver bankNo bankName company context1 context2}  
    count_row = 1

    results.each do |o|  
      sheet[count_row,0]=count_row 
      sheet[count_row,1]=o.registration_no
      sheet[count_row,2]=o.qr_attr.blank? ? "" : o.qr_attr.try(:name)
      sheet[count_row,3]=o.qr_attr.blank? ? "" : o.qr_attr.try(:phone)
      sheet[count_row,4]="1"
      sheet[count_row,5]=o.operated_at.blank? ? "" : o.operated_at.strftime('%Y-%m-%d').to_s
      sheet[count_row,6]=o.result.blank? ? "" : o.result
      sheet[count_row,7]=""
      sheet[count_row,8]=""
      sheet[count_row,9]="EMS"
      sheet[count_row,10]=""
      sheet[count_row,11]=""

      count_row += 1
    end
    book.write file_path
    # book.write xls_report  #temp
    # xls_report.string      #temp
  end

  
end


