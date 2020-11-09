class ImportFile < ActiveRecord::Base
  belongs_to :business
  belongs_to :unit
  belongs_to :user
  has_many :query_results

  STATUS = { success: '成功', fail: '失败', waiting: '待处理', doing: '处理中'}
  IMPORT_TYPE = { QueryResult: '信息导入', ReturnResult: '退件导入'}
  IS_QUERY = { true: '是', false: '否'}

  DOWNLOAD_DIRECT = "#{Rails.root}/public/download/"
  
  def status_name
    status.blank? ? "" : ImportFile::STATUS["#{status}".to_sym]
  end

  def import_type_name
    import_type.blank? ? "" : ImportFile::IMPORT_TYPE["#{import_type}".to_sym]
  end

  def is_query_name
    is_query.blank? ? "" : ImportFile::IS_QUERY["#{is_query}".to_sym]
  end

  def self.upload_info(file, business_id, order_date, import_type, current_user, is_query, is_update)
    if !file.original_filename.empty?
        direct = "#{Rails.root}/upload/info/"
        filename = "#{Time.now.to_f}_#{file.original_filename}"

        file_path = direct + filename
        File.open(file_path, "wb") do |f|
          f.write(file.read)
        end

        ImportFile.create! file_name: filename, file_path: file_path, import_date: order_date, user_id: current_user.id, unit_id: current_user.unit.id, business_id: business_id, import_type: import_type, is_query: is_query, is_update: is_update

        file_path
      end
  end

  def self.get_indexs(title_row)
    indexs_hash = Hash.new

    if !title_row.index("挂号编号").blank?
      indexs_hash["registration_no_index"] = title_row.index("挂号编号")
    elsif !title_row.index("约投号码").blank?
      indexs_hash["registration_no_index"] = title_row.index("约投号码")
    elsif !title_row.index("邮件号").blank?
      indexs_hash["registration_no_index"] = title_row.index("邮件号")
    end
    if !title_row.index("邮编").blank?
      indexs_hash["postcode_index"] = title_row.index("邮编")
    end
    if !title_row.index("数据日期").blank?
      indexs_hash["data_date_index"] = title_row.index("数据日期")
    end
    if !title_row.index("批次日期").blank?
      indexs_hash["batch_date_index"] = title_row.index("批次日期")
    elsif !title_row.index("收寄时间").blank?
      indexs_hash["batch_date_index"] = title_row.index("收寄时间")
    end
    if !title_row.index("联名卡标识").blank?
      indexs_hash["lmk_index"] = title_row.index("联名卡标识")
    end
    if !title_row.index("识别码").blank?
      indexs_hash["id_code_index"] = title_row.index("识别码")
    end
    if !title_row.index("文件SN号").blank?
      indexs_hash["sn_index"] = title_row.index("文件SN号")
    end
    if !title_row.index("发卡行").blank?
      indexs_hash["issue_bank_index"] = title_row.index("发卡行")
    end
    if !title_row.index("姓名").blank?
      indexs_hash["name_index"] = title_row.index("姓名")
    elsif !title_row.index("收件人").blank?
      indexs_hash["name_index"] = title_row.index("收件人")
    end
    if !title_row.index("网点编号").blank?
      indexs_hash["bank_no_index"] = title_row.index("网点编号")
    end
    if !title_row.index("电话").blank?
      indexs_hash["phone_index"] = title_row.index("电话")
    end
    if !title_row.index("地址").blank?
      indexs_hash["address_index"] = title_row.index("地址")
    end
    if !title_row.index("身份证号码").blank?
      indexs_hash["id_num_index"] = title_row.index("身份证号码")
    end
    if !title_row.index("寄达省名称").blank?
      indexs_hash["province_index"] = title_row.index("寄达省名称")
    end
    if !title_row.index("寄达市名称").blank?
      indexs_hash["city_index"] = title_row.index("寄达市名称")
    end
    if !title_row.index("寄达区名称").blank?
      indexs_hash["district_index"] = title_row.index("寄达区名称")
    end
    if !title_row.index("重量(克)").blank?
      indexs_hash["weight_index"] = title_row.index("重量(克)")
    end
    if !title_row.index("总邮资").blank?
      indexs_hash["price_index"] = title_row.index("总邮资")
    end
    if !title_row.index("订单号").blank?
      indexs_hash["business_code_index"] = title_row.index("订单号")
    end

    return indexs_hash
  end

  def self.get_infos(rowarr, indexs_hash)
    infos_hash = Hash.new

    registration_no_index = indexs_hash["registration_no_index"]
    postcode_index = indexs_hash["postcode_index"]
    data_date_index = indexs_hash["data_date_index"]
    batch_date_index = indexs_hash["batch_date_index"]
    lmk_index = indexs_hash["lmk_index"]
    id_code_index = indexs_hash["id_code_index"]
    sn_index = indexs_hash["sn_index"]
    issue_bank_index = indexs_hash["issue_bank_index"]
    name_index = indexs_hash["name_index"]
    bank_no_index = indexs_hash["bank_no_index"]
    phone_index = indexs_hash["phone_index"]
    address_index = indexs_hash["address_index"]
    id_num_index = indexs_hash["id_num_index"]
    province_index = indexs_hash["province_index"]
    city_index = indexs_hash["city_index"]
    district_index = indexs_hash["district_index"]
    weight_index = indexs_hash["weight_index"]
    price_index = indexs_hash["price_index"]
    business_code_index = indexs_hash["business_code_index"]

    infos_hash["registration_no"] = registration_no_index.blank? ? "" : (rowarr[registration_no_index].blank? ? "" : rowarr[registration_no_index].to_s.gsub(' ','').split('.0')[0])
    infos_hash["postcode"] = postcode_index.blank? ? "" : (rowarr[postcode_index].blank? ? "" : rowarr[postcode_index].to_s.split('.0')[0])
    infos_hash["data_date"] = data_date_index.blank? ? nil : (rowarr[data_date_index].blank? ? nil : DateTime.parse(rowarr[data_date_index].to_s.split(".0")[0]).strftime('%Y-%m-%d'))
    infos_hash["batch_date"] = batch_date_index.blank? ? nil : (rowarr[batch_date_index].blank? ? nil : DateTime.parse(rowarr[batch_date_index].to_s.split(".0")[0]).strftime('%Y-%m-%d'))
    infos_hash["lmk"] = lmk_index.blank? ? "" : (rowarr[lmk_index].blank? ? "" : rowarr[lmk_index].to_s.split('.0')[0])
    infos_hash["id_code"] = id_code_index.blank? ? "" : (rowarr[id_code_index].blank? ? "" : rowarr[id_code_index].to_s.split('.0')[0])
    infos_hash["sn"] = sn_index.blank? ? "" : (rowarr[sn_index].blank? ? "" : rowarr[sn_index].to_s.split('.0')[0])
    infos_hash["issue_bank"] = issue_bank_index.blank? ? "" : (rowarr[issue_bank_index].blank? ? "" : rowarr[issue_bank_index].to_s.split('.0')[0])
    infos_hash["name"] = name_index.blank? ? "" : (rowarr[name_index].blank? ? "" : rowarr[name_index].to_s.split('.0')[0])
    infos_hash["bank_no"] = bank_no_index.blank? ? "" : (rowarr[bank_no_index].blank? ? "" : rowarr[bank_no_index].to_s.split('.0')[0])
    infos_hash["phone"] = phone_index.blank? ? "" : (rowarr[phone_index].blank? ? "" : rowarr[phone_index].to_s.split('.0')[0])
    infos_hash["address"] = address_index.blank? ? "" : (rowarr[address_index].blank? ? "" : rowarr[address_index].to_s.split('.0')[0])
    infos_hash["id_num"] = id_num_index.blank? ? "" : (rowarr[id_num_index].blank? ? "" : rowarr[id_num_index].to_s.split('.0')[0])
    infos_hash["province"] = province_index.blank? ? "" : (rowarr[province_index].blank? ? "" : rowarr[province_index].to_s.split('.0')[0])
    infos_hash["city"] = city_index.blank? ? "" : (rowarr[city_index].blank? ? "" : rowarr[city_index].to_s.split('.0')[0])
    infos_hash["district"] = district_index.blank? ? "" : (rowarr[district_index].blank? ? "" : rowarr[district_index].to_s.split('.0')[0])
    infos_hash["weight"] = weight_index.blank? ? 0.00 : (rowarr[weight_index].blank? ? 0.00 : rowarr[weight_index].to_f.round(2))
    infos_hash["price"] = price_index.blank? ? 0.00 : (rowarr[price_index].blank? ? 0.00 : rowarr[price_index].to_f.round(2))
    infos_hash["business_code"] = business_code_index.blank? ? "" : (rowarr[business_code_index].blank? ? "" : rowarr[business_code_index].to_s.split('.0')[0])

    return infos_hash
  end

  def self.process_datas(result_object, f, title_row, infos_hash)
    import_object = result_object.find_by_registration_no infos_hash["registration_no"]
    status = nil
    if f.is_query
      if import_object.blank? 
        status = "waiting"
      else
        status = import_object.status.blank? ? "waiting" : import_object.status
      end
    else
      status = "own"
    end

    if import_object.blank?
      if result_object.is_a? QueryResult
        import_object = result_object.create! registration_no: infos_hash["registration_no"], postcode: infos_hash["postcode"], order_date: f.import_date, unit_id: f.unit_id, business_id: f.business_id, source: "邮政数据查询", status: status, business_code: infos_hash["business_code"], import_file_id: f.id
      else
        import_object = result_object.create! registration_no: infos_hash["registration_no"], postcode: infos_hash["postcode"], order_date: f.import_date, unit_id: f.unit_id, business_id: f.business_id, source: "邮政数据查询", status: status, import_file_id: f.id
      end
      if (!title_row.index("联名卡标识").blank?) || (!title_row.index("身份证号码").blank?) || (!title_row.index("收寄时间").blank?)
        QrAttr.create! data_date: infos_hash["data_date"], batch_date: infos_hash["batch_date"], lmk: infos_hash["lmk"], id_code: infos_hash["id_code"], sn: infos_hash["sn"],  issue_bank: infos_hash["issue_bank"], name: infos_hash["name"], bank_no: infos_hash["bank_no"], phone: infos_hash["phone"], address: infos_hash["address"], query_result_id: import_object.id, id_num: infos_hash["id_num"], province: infos_hash["province"], city: infos_hash["city"], district: infos_hash["district"], weight: infos_hash["weight"], price: infos_hash["price"]
      end
    else
      if f.is_update
        if (!title_row.index("联名卡标识").blank?) || (!title_row.index("身份证号码").blank?) || (!title_row.index("收寄时间").blank?)
          import_object.update order_date: f.import_date, status: status, business_code: infos_hash["business_code"], import_file_id: f.id

          complete_qr_attr(import_object, infos_hash)
        else
          if f.is_query
            import_object.update order_date: f.import_date, status: status, business_code: infos_hash["business_code"], import_file_id: f.id
          else
            import_object.update order_date: f.import_date, business_code: infos_hash["business_code"], import_file_id: f.id
          end
        end
      else
        if (!title_row.index("联名卡标识").blank?) || (!title_row.index("身份证号码").blank?) || (!title_row.index("收寄时间").blank?)
          complete_qr_attr(import_object, infos_hash)
        end
      end
    end
  end

  def self.complete_qr_attr(import_object, infos_hash)
    if !import_object.qr_attr.blank?
      qr_attr = import_object.qr_attr
      infos_hash.keys.each do |x|
        qr_attr.send("#{x}=", infos_hash[x]) if (qr_attr.respond_to? "#{x}=") && !infos_hash[x].blank?
      end
      qr_attr.save!
    else
      QrAttr.create! data_date: infos_hash["data_date"], batch_date: infos_hash["batch_date"], lmk: infos_hash["lmk"], id_code: infos_hash["id_code"], sn: infos_hash["sn"],  issue_bank: infos_hash["issue_bank"], name: infos_hash["name"], bank_no: infos_hash["bank_no"], phone: infos_hash["phone"], address: infos_hash["address"], query_result_id: import_object.id, id_num: infos_hash["id_num"], province: infos_hash["province"], city: infos_hash["city"], district: infos_hash["district"], weight: infos_hash["weight"], price: infos_hash["price"]
    end
  end

  @@import_lock = Mutex.new

  def self.import_data with_thread = false
    # direct = "#{Rails.root}/public/download/"
    trans_error = false
    current_line = nil
    message = ""
    txt = ""
    title_row = nil
    indexs_hash = nil

       
    if !File.exist?(DOWNLOAD_DIRECT)
      Dir.mkdir(DOWNLOAD_DIRECT)          
    end

    f = ImportFile.where(status: "waiting").first
    if f.blank?
      return
    end

    if ! ImportFile.where(status: "doing").count == 0
      f.update desc: "等待，前面有文件正在处理中"
      return
    end
      
    f.update status: "doing"
        
    sheet_error = []
    rowarr = [] 
    instance=nil
    Rails.logger.info "*********** begin roo instance***********"

    if f.file_path.try :end_with?, '.xlsx'
      instance= Roo::Excelx.new(f.file_path)
    elsif f.file_path.try :end_with?, '.xls'
      instance= Roo::Excel.new(f.file_path)
    elsif f.file_path.try :end_with?, '.csv'
      instance= Roo::CSV.new(f.file_path)
    else
      f.update status:"fail", desc: "文件后缀名必须为xlsx,xls或csv"
      return false
    end

    f.update total_rows: instance.count

    instance.default_sheet = instance.sheets.first
    result_object = eval(f.import_type)
          
    line = 2
    start_time  = Time.now

    if ! with_thread
      ActiveRecord::Base.transaction do
        begin
          title_row = instance.row(1)
          indexs_hash = get_indexs(title_row)
          row_count = instance.count
    
          Rails.logger.info "*********** begin #{instance.count}***********"
    
          while (line <= row_count)
            
            current_line = line
            
            rowarr = instance.row(current_line)
            line += 1
            infos_hash = get_infos(rowarr, indexs_hash)
            # Rails.logger.info "*********** time1 #{Time.now - start_time}***********"

            if infos_hash["registration_no"].blank?
              txt = "缺少挂号编号或约投号码或邮件号" + "(第" + current_line.to_s + "行)"
              # puts txt
              sheet_error << (rowarr << txt)
              next
            end
            # Rails.logger.info "*********** time2 #{Time.now - start_time}***********"
            begin
              # Rails.logger.info "*********** begin process #{line}***********"
              process_datas(result_object, f, title_row, infos_hash)
            rescue ActiveRecord::RecordInvalid => e
              txt = e.message + "(第" + current_line.to_s + "行)"
              sheet_error << (rowarr << txt)
              next
            end
            # Rails.logger.info "*********** time2 #{Time.now - start_time}***********"
            if current_line%1000 == 0
              Rails.logger.info "*********** " + Time.now.strftime("%Y-%m-%d %H:%M:%S") + ", 文件<" + f.file_name + ">已处理到第" + current_line.to_s + "行 ***********"
            end
            # Rails.logger.info "*********** time4 #{Time.now - start_time}***********"
          end
        rescue Exception => e
          trans_error = true
          message = e.message + "(第" + current_line.to_s + "行)"
          Rails.logger.error e.message + "(第" + current_line.to_s + "行)"
          Rails.logger.error e.backtrace
          # raise ActiveRecord::Rollback
        end
      end
    else
      title_row = instance.row(1)
      indexs_hash = get_indexs(title_row)
      row_count = instance.count
    
      i = (row_count-1) > 5 ? 5 : (row_count-1)

      ts = []
      line = 2
      i.times.each do |x|
        t = Thread.new do
          begin
            while (line <= row_count)
              if line > row_count
                # puts "===#{line}==="
                break
              end 
              @@import_lock.synchronize do
                current_line = line
                rowarr = instance.row(current_line)
                line += 1
              end
            
              infos_hash = get_infos(rowarr, indexs_hash)

              if infos_hash["registration_no"].blank?
                txt = "缺少挂号编号或约投号码或邮件号" + "(第" + current_line.to_s + "行)"
                # puts txt
                sheet_error << (rowarr << txt)
                next
              end
              # Rails.logger.info "第" + current_line.to_s + "行, " + Time.now.strftime("%Y-%m-%d %H:%M:%S")
              ActiveRecord::Base.connection_pool.with_connection do
                begin
                  process_datas(result_object, f, title_row, infos_hash)
                rescue ActiveRecord::RecordInvalid => e
                  txt = e.message + "(第" + current_line.to_s + "行)"
                  sheet_error << (rowarr << txt)
                  next
                end
                ActiveRecord::Base.clear_active_connections!
              end
              if current_line%1000 == 0
                Rails.logger.info "*********** " + Time.now.strftime("%Y-%m-%d %H:%M:%S") + ", 文件<" + f.file_name + ">已处理到第" + current_line.to_s + "行 ***********"
              end
            end
          rescue Exception => e
            trans_error = true
            message = e.message + "(第" + current_line.to_s + "行)"
            Rails.logger.error e.message + "(第" + current_line.to_s + "行)"
            Rails.logger.error e.backtrace
            # raise ActiveRecord::Rollback
          end
        end
        ts << t
      end
      ts.each do |x|
        x.join
      end
    end

    Rails.logger.info "*********** end #{Time.now - start_time}***********"
    if trans_error
      f.update status: "fail", desc: message
    elsif !sheet_error.blank?
      filename = "Error_Infos_#{Time.now.strftime('%Y%m%d %H:%M:%S')}.xls"
      file_path = DOWNLOAD_DIRECT + filename
            
      exporterrorinfos_xls_content_for(sheet_error, title_row, file_path)
      if sheet_error.size == (row_count - 1)
        f.update status: "fail", desc: "失败", err_file_path: file_path
      else
        f.update status: "success", desc: "部分导入成功,共#{sheet_error.size}行失败,可能原因是#{txt}", err_file_path: file_path
      end
    else
      f.update status: "success", desc: "成功"
    end
  end

  

 #  def self.import_data_with_thread
 #    direct = "#{Rails.root}/public/download/"
 #    trans_error = false
 #    current_line = nil
 #    message = ""
 #    txt = ""
 #    infos_hash = Hash.new
 #    indexs_hash = Hash.new
       
 #    if !File.exist?(direct)
 #      Dir.mkdir(direct)          
 #    end
 #    f = ImportFile.where(status: "waiting").first

 #    if ImportFile.where(status: "doing").count == 0
  #     if file = f.file_path
 #        ActiveRecord::Base.transaction do           
  #         begin
  #           f.update status: "doing"
  #         rescue Exception => e
  #           Rails.logger.error e.message 
  #           raise ActiveRecord::Rollback
  #         end
 #        end
          
 #        sheet_error = []
 #        rowarr = [] 
 #        instance=nil
 #        Rails.logger.info "begin"
 #        if file.end_with?('.xlsx')
 #          instance= Roo::Excelx.new(file)
 #        elsif file.end_with?('.xls')
  #         instance= Roo::Excel.new(file)
 #        elsif file.end_with?('.csv')
 #          instance= Roo::CSV.new(file)
 #        else
 #          f.update status:"fail", desc: "文件后缀名必须为xlsx,xls或csv"
 #          return false
 #        end
                
 #        Rails.logger.info "File read: "+Time.now.strftime("%Y-%m-%d %H:%M:%S")
 #        instance.default_sheet = instance.sheets.first
 #        title_row = instance.row(1)
 #        indexs_hash = get_indexs(title_row)

 #        result_object = eval(f.import_type)
 #        row_count = instance.count

  #       Rails.logger.info "*********** begin #{row_count}***********"
 #        start_time = Time.now
  #       i = (row_count-1) > 5 ? 5 : (row_count-1)

  #       ts = []
  #       line = 2
  #       i.times.each do |x|
  #         t = Thread.new do
 #            begin
  #             while (line <= )
  #               if line > row_count
  #                 puts "===#{line}==="
  #                 break
  #               end 
  #               @@import_lock.synchronize do
  #                 current_line = line
  #                 rowarr = instance.row(current_line)
  #                 line += 1
  #               end
              
  #               infos_hash = get_infos(rowarr, indexs_hash)

  #               if infos_hash["registration_no"].blank?
  #                 txt = "缺少挂号编号或约投号码或邮件号" + "(第" + current_line.to_s + "行)"
  #                 # puts txt
  #                 sheet_error << (rowarr << txt)
  #                 next
  #               end
  #               # Rails.logger.info "第" + current_line.to_s + "行, " + Time.now.strftime("%Y-%m-%d %H:%M:%S")
  #               ActiveRecord::Base.connection_pool.with_connection do
  #                 begin
  #                   process_datas(result_object, f, title_row, infos_hash)
  #                 rescue ActiveRecord::RecordInvalid => e
  #                   txt = e.message + "(第" + current_line.to_s + "行)"
  #                   sheet_error << (rowarr << txt)
  #                   next
  #                 end
  #               end
  #               if current_line%1000 == 0
  #                 Rails.logger.info "*********** " + Time.now.strftime("%Y-%m-%d %H:%M:%S") + ", 文件<" + f.file_name + ">已处理到第" + current_line.to_s + "行 ***********"
  #               end
 #              end
  #           rescue Exception => e
  #             trans_error = true
  #             message = e.message + "(第" + current_line.to_s + "行)"
  #             Rails.logger.error e.message + "(第" + current_line.to_s + "行)"
  #             Rails.logger.error e.backtrace
  #             # raise ActiveRecord::Rollback
  #           end
  #         end
  #         ts << t
  #       end
  #       ts.each do |x|
  #         x.join
  #       end
  #       Rails.logger.info "*********** end #{Time.now - start_time}***********"
  #       if trans_error
  #         f.update status: "fail", desc: message
  #       elsif !sheet_error.blank?
 #          filename = "Error_Infos_#{Time.now.strftime('%Y%m%d %H:%M:%S')}.xls"
 #          file_path = direct + filename
                
 #          exporterrorinfos_xls_content_for(sheet_error, title_row, file_path)
 #          f.update status: "success", desc: "部分导入成功,共#{sheet_error.size}行失败,可能原因是#{txt}", err_file_path: file_path
 #        else
  #         f.update status: "success", desc: "成功"
  #       end
 #      end
 #    else
 #      f.update desc: "等待，前面有文件正在处理中"
 #    end 
  # end

  def self.exporterrorinfos_xls_content_for(obj,title_row,file_path)
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "Infos"  

    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
    red = Spreadsheet::Format.new :color => :red
    sheet1.row(0).default_format = blue 
     
    sheet1.row(0).concat title_row
    size = obj.first.size 
              
    count_row = 1
    obj.each do |obj|
      count = 0
      while count<=size
        sheet1[count_row,count]=obj[count]
        count += 1
      end
      
      count_row += 1
    end 
    book.write file_path
  end
end
