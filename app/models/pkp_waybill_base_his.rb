class PkpWaybillBaseHis  < PkpDataRecordHis
  self.table_name = 'pkp_waybill_bases_2025'
  self.primary_key = 'id' 

  #写一个方法从2025年1月开始，到2025年11月底结束，按月调用get_query_records方法，code是:YwtbInterface，总共调用11次
  def self.get_query_records_schedule_ywtb
    (1..11).each do |month|
      start_date = Date.new(2025, month, 1)
      end_date = start_date.end_of_month
      get_query_records(:YwtbInterface, start_date, end_date)
    end
  end

 

  #写一个方法在当天目录下创建一个date文件，用于记录当前get_query_records_schedule_ywtb_daily所到的天数，从2025年1月1日开始，到2025年11月30日结束。每次调用get_query_records_schedule_ywtb_daily方法时，先读取date文件中的日期，然后调用get_query_records_schedule_ywtb_daily方法处理该日期的数据，处理完成后，将date文件中的日期加1天，保存到date文件中，供下次调用使用。
  def self.get_query_records_schedule_ywtb_daily_with_file
    #写一下日志，调用时间
    date_file_path = Rails.root.join('date.txt')
    if !File.exist?(date_file_path)
      File.open(date_file_path, 'w') do |f|
        f.write('2025-01-01')
      end
    end

    current_date_str = File.read(date_file_path).strip
    current_date = Date.parse(current_date_str)

    end_date = Date.new(2025, 11, 30)

    if current_date <= end_date
      # get_query_records(:YwtbInterface, current_date, current_date + 1.day)

      next_date = current_date + 1.day
      File.open(date_file_path, 'w') do |f|
        f.write(next_date.strftime('%Y-%m-%d'))
      end
      Rails.logger.info "Ywtb 2025 processing date: #{current_date} start at: #{Time.now}"
      get_query_records(:YwtbInterface, current_date, current_date + 1.day)
      Rails.logger.info "Ywtb 2025 processing date: #{current_date} end at: #{Time.now}"
    end
  end

  #写一个方法根据输入值重置date文件中的日期，输入值格式为yyyy-mm-dd
  def self.reset_date_file(date_str)
    date_file_path = Rails.root.join('date.txt')
    File.open(date_file_path, 'w') do |f|
      f.write(date_str)
    end
  end

  def self.get_query_records(code, start_date, end_date)
    businesses = I18n.t(code)[:businesses]
    businesses.each do |x|
      if x[:need_data_from_pkp]
        business_no = x[:business_no]
        business = Business.find_by no: business_no

        if !business.blank?
          sender_no = x[:sender_no]
          
          pkp_waybill_bases = self.where(sender_no: sender_no).where("biz_occur_date >= '#{start_date}' and biz_occur_date < '#{end_date}'")
          ActiveRecord::Base.transaction do
            pkp_waybill_bases.each do |x|
              x.create_from_pkp_waybill_base(business)
            end
          end
        end
      end
    end
  end

  def create_from_pkp_waybill_base(business)
    query_result = QueryResult.find_or_initialize_by(registration_no: self.waybill_no, business: business)

    query_result.business = business
    query_result.unit = business.unit

    query_result.registration_no = self.waybill_no
    query_result.status = QueryResult::STATUS[:waiting]
    query_result.source = 'ESB'
    
    query_result.business_code ||= self.logistics_order_no
    query_result.business_code ||= self.waybill_no
    
    query_result.postcode = self.sender_postcode
    query_result.order_date = self.biz_occur_date.to_date

    query_result.is_posting = true
    query_result.is_sent = false
    query_result.to_send = true

    PkpDataRecordHis.update_query_result_status_from_mail_trace_his(query_result)

    if query_result.qr_attr.blank?
      query_result.qr_attr = QrAttr.new
    end
    qr_attr = query_result.qr_attr
    qr_attr.name = self.receiver_linker
    qr_attr.address = self.receiver_addr
    qr_attr.province = self.receiver_province_name
    qr_attr.city = self.receiver_city_name
    qr_attr.district = self.receiver_county_name
    qr_attr.phone = self.receiver_mobile || self.receiver_fixtel
    qr_attr.batch_date = self.biz_occur_date
    qr_attr.save!
    query_result.save!
  end

  #参照QueryResult.get_result_with_status方法，写一个通过QueryResult的registration_no找到MailTraceHis的相关记录，并根据最后一条MailTraceHis的status去更新QueryResult的状态的方法
  def self.update_query_result_status_from_mail_trace_his(query_result)
    mail_trace_his = MailTraceHis.find_by(mail_no: query_result.registration_no)
    if !mail_trace_his.blank?
      query_result.status = mail_trace_his.status
      query_result.operated_at = mail_trace_his.operated_at
      last_mail_trace_his = mail_trace_his.mail_trace_his_details.order(:created_at).last
      if !last_mail_trace_his.blank?
        traces = JSON.parse(last_mail_trace_his.traces.gsub("=>", ":"))
        last_trace = traces.last

        opt_code = last_trace["opCode"]
        opt_desc = last_trace["opDesc"]
        opt_time = last_trace["opTime"]
        
        status = QueryResult::STATUS[:waiting]

        if !opt_code.blank?
          if opt_code.eql? '704'
            if opt_desc.include?('已妥收')
              status = QueryResult::STATUS[:own]
            elsif opt_desc.include?('已代收') && (opt_desc.include?('家人') || opt_desc.include?('朋友') || opt_desc.include?('同事') || opt_desc.include?('邻居'))
              status = QueryResult::STATUS[:other]
            else
              status = QueryResult::STATUS[:unit]
            end
          elsif opt_code.eql? '748'
            status = QueryResult::STATUS[:own]
          elsif opt_code.eql? '747'
            status = QueryResult::STATUS[:returns]
          end
        end

        query_result.status = status
        # query_result.last_received_at = opt_time.present? ? DateTime.parse(opt_time) : nil
        query_result.save!
      end
    end
  end
  
end