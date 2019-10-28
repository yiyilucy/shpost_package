class ImportFile < ActiveRecord::Base
	belongs_to :business
	belongs_to :unit
	belongs_to :user

	STATUS = { success: '成功', fail: '失败', waiting: '待处理', doing: '处理中'}
	IMPORT_TYPE = { QueryResult: '信息导入', ReturnResult: '退件导入'}
	IS_QUERY = { true: '是', false: '否'}
	
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

	      ImportFile.create! file_name: filename, file_path: file_path, import_date: order_date, user_id: current_user.id, unit_id: current_user.unit.id, business_id: business_id, err_file_path: file_path, import_type: import_type, is_query: is_query, is_update: is_update

	      file_path
	    end
	end

	@@import_lock = Mutex.new

  def self.import_data
    direct = "#{Rails.root}/public/download/"
    trans_error = false
    current_line = nil
    message = ""
    txt = ""
       
    if !File.exist?(direct)
      Dir.mkdir(direct)          
    end
    f = ImportFile.where(status: "waiting").first

    if ImportFile.where(status: "doing").count == 0
	    if file = f.file_path
      	ActiveRecord::Base.transaction do           
	        begin
	          f.update status: "doing"
	        rescue Exception => e
	          Rails.logger.error e.message 
	          raise ActiveRecord::Rollback
	        end
      	end
      		
    		sheet_error = []
      	rowarr = [] 
        instance=nil
        Rails.logger.info "begin"
        if file.end_with?('.xlsx')
        	instance= Roo::Excelx.new(file)
        elsif file.end_with?('.xls')
		    	instance= Roo::Excel.new(file)
        elsif file.end_with?('.csv')
          instance= Roo::CSV.new(file)
        else
        	f.update status:"fail", desc: "文件后缀名必须为xlsx,xls或csv"
        	return false
        end
                
      	Rails.logger.info "File read: "+Time.now.strftime("%Y-%m-%d %H:%M:%S")
        instance.default_sheet = instance.sheets.first
        title_row = instance.row(1)
        if !title_row.index("挂号编号").blank?
          registration_no_index = title_row.index("挂号编号")
        elsif !title_row.index("约投号码").blank?
          registration_no_index = title_row.index("约投号码")
        elsif !title_row.index("邮件号").blank?
          registration_no_index = title_row.index("邮件号")
        end
        if !title_row.index("邮编").blank?
          postcode_index = title_row.index("邮编")
        end
        if !title_row.index("数据日期").blank?
          data_date_index = title_row.index("数据日期")
        end
        if !title_row.index("批次日期").blank?
          batch_date_index = title_row.index("批次日期")
        elsif !title_row.index("收寄时间").blank?
          batch_date_index = title_row.index("收寄时间")
        end
        if !title_row.index("联名卡标识").blank?
          lmk_index = title_row.index("联名卡标识")
        end
        if !title_row.index("识别码").blank?
          id_code_index = title_row.index("识别码")
        end
        if !title_row.index("文件SN号").blank?
          sn_index = title_row.index("文件SN号")
        end
        if !title_row.index("发卡行").blank?
          issue_bank_index = title_row.index("发卡行")
        end
        if !title_row.index("姓名").blank?
          name_index = title_row.index("姓名")
        elsif !title_row.index("收件人").blank?
          name_index = title_row.index("收件人")
        end
        if !title_row.index("网点编号").blank?
          bank_no_index = title_row.index("网点编号")
        end
        if !title_row.index("电话").blank?
          phone_index = title_row.index("电话")
        end
        if !title_row.index("地址").blank?
          address_index = title_row.index("地址")
        end
        if !title_row.index("身份证号码").blank?
          id_num_index = title_row.index("身份证号码")
        end
        if !title_row.index("寄达省名称").blank?
          province_index = title_row.index("寄达省名称")
        end
        if !title_row.index("寄达市名称").blank?
          city_index = title_row.index("寄达市名称")
        end
        if !title_row.index("寄达区名称").blank?
          district_index = title_row.index("寄达区名称")
        end
        if !title_row.index("重量(克)").blank?
          weight_index = title_row.index("重量(克)")
        end
        if !title_row.index("总邮资").blank?
          price_index = title_row.index("总邮资")
        end

        result_object = eval(f.import_type)

		    Rails.logger.info "*********** begin ***********"

		    i = (instance.count-1) > 50 ? 50 : (instance.count-1)

		    ts = []
		    line = 2
		    i.times.each do |x|
		    	t = Thread.new do
          	begin
	            while (line <= instance.count)
	            	if line > instance.count
	            		puts "===#{line}==="
		            	break
		            end 
	            	@@import_lock.synchronize do
		            	current_line = line
		            	rowarr = instance.row(current_line)
		            	line += 1
		            end
	            
		            registration_no = registration_no_index.blank? ? "" : (rowarr[registration_no_index].blank? ? "" : rowarr[registration_no_index].to_s.gsub(' ','').split('.0')[0])
		            postcode = postcode_index.blank? ? "" : (rowarr[postcode_index].blank? ? "" : rowarr[postcode_index].to_s.split('.0')[0])
		            data_date = data_date_index.blank? ? nil : (rowarr[data_date_index].blank? ? nil : DateTime.parse(rowarr[data_date_index].to_s.split(".0")[0]).strftime('%Y-%m-%d'))
              	batch_date = batch_date_index.blank? ? nil : (rowarr[batch_date_index].blank? ? nil : DateTime.parse(rowarr[batch_date_index].to_s.split(".0")[0]).strftime('%Y-%m-%d'))
              	lmk = lmk_index.blank? ? "" : (rowarr[lmk_index].blank? ? "" : rowarr[lmk_index].to_s.split('.0')[0])
              	id_code = id_code_index.blank? ? "" : (rowarr[id_code_index].blank? ? "" : rowarr[id_code_index].to_s.split('.0')[0])
              	sn = sn_index.blank? ? "" : (rowarr[sn_index].blank? ? "" : rowarr[sn_index].to_s.split('.0')[0])
              	issue_bank = issue_bank_index.blank? ? "" : (rowarr[issue_bank_index].blank? ? "" : rowarr[issue_bank_index].to_s.split('.0')[0])
              	name = name_index.blank? ? "" : (rowarr[name_index].blank? ? "" : rowarr[name_index].to_s.split('.0')[0])
              	bank_no = bank_no_index.blank? ? "" : (rowarr[bank_no_index].blank? ? "" : rowarr[bank_no_index].to_s.split('.0')[0])
              	phone = phone_index.blank? ? "" : (rowarr[phone_index].blank? ? "" : rowarr[phone_index].to_s.split('.0')[0])
              	address = address_index.blank? ? "" : (rowarr[address_index].blank? ? "" : rowarr[address_index].to_s.split('.0')[0])
              	id_num = id_num_index.blank? ? "" : (rowarr[id_num_index].blank? ? "" : rowarr[id_num_index].to_s.split('.0')[0])
              	province = province_index.blank? ? "" : (rowarr[province_index].blank? ? "" : rowarr[province_index].to_s.split('.0')[0])
              	city = city_index.blank? ? "" : (rowarr[city_index].blank? ? "" : rowarr[city_index].to_s.split('.0')[0])
              	district = district_index.blank? ? "" : (rowarr[district_index].blank? ? "" : rowarr[district_index].to_s.split('.0')[0])
              	weight = weight_index.blank? ? 0.00 : (rowarr[weight_index].blank? ? 0.00 : rowarr[weight_index].to_f.round(2))
              	price = price_index.blank? ? 0.00 : (rowarr[price_index].blank? ? 0.00 : rowarr[price_index].to_f.round(2))

		            if registration_no.blank?
		              txt = "缺少挂号编号或约投号码或邮件号" + "(第" + current_line.to_s + "行)"
		              # puts txt
		              sheet_error << (rowarr << txt)
		              next
		            end
	            	# Rails.logger.info "第" + current_line.to_s + "行, " + Time.now.strftime("%Y-%m-%d %H:%M:%S")
	            	ActiveRecord::Base.connection_pool.with_connection do
			            begin
			            	import_object = result_object.find_by_registration_no registration_no
			            	status = f.is_query ? "waiting" : "own"

			            	if import_object.blank?
			            		import_object = result_object.create! registration_no: registration_no, postcode: postcode, order_date: f.import_date, unit_id: f.unit_id, business_id: f.business_id, source: "邮政数据查询", status: status
		            			if (!title_row.index("联名卡标识").blank?) || (!title_row.index("身份证号码").blank?) || (!title_row.index("收寄时间").blank?)
		            				QrAttr.create! data_date: data_date, batch_date: batch_date, lmk: lmk, id_code: id_code, sn: sn,  issue_bank: issue_bank, name: name, bank_no: bank_no, phone: phone, address: address, query_result_id: import_object.id, id_num: id_num, province: province, city: city, district: district, weight: weight, price: price
		            			end
		            		else
		            			if f.is_update
			            			if (!title_row.index("联名卡标识").blank?) || (!title_row.index("身份证号码").blank?) || (!title_row.index("收寄时间").blank?)
			            				import_object.update order_date: f.import_date, status: status

		            					if !import_object.qr_attr.blank?
		              	  			import_object.qr_attr.update data_date: data_date, batch_date: batch_date, lmk: lmk, id_code: id_code, sn: sn, issue_bank: issue_bank, name: name, bank_no: bank_no, phone: phone, address: address, id_num: id_num, province: province, city: city, district: district, weight: weight, price: price
		              	  		else
		              	  			QrAttr.create! data_date: data_date, batch_date: batch_date, lmk: lmk, id_code: id_code, sn: sn,  issue_bank: issue_bank, name: name, bank_no: bank_no, phone: phone, address: address, query_result_id: import_object.id, id_num: id_num, province: province, city: city, district: district, weight: weight, price: price
		              	  		end
			              	  else
			            				if is_query
			            					import_object.update order_date: f.import_date, status: status
			            				else
			            					import_object.update order_date: f.import_date
			            				end
			            			end
			            		end
			            	end
		            	rescue ActiveRecord::RecordInvalid => e
		             		txt = e.message + "(第" + current_line.to_s + "行)"
	              		sheet_error << (rowarr << txt)
	              		next
		            	end
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
		    Rails.logger.info "*********** end ***********"
		    if trans_error
				  f.update status: "fail", desc: message
				elsif !sheet_error.blank?
          filename = "Error_Infos_#{Time.now.strftime('%Y%m%d %H:%M:%S')}.xls"
          file_path = direct + filename
		            
          exporterrorinfos_xls_content_for(sheet_error, title_row, file_path)
          f.update status: "success", desc: "部分导入成功,共#{sheet_error.size}行失败,可能原因是#{txt}", err_file_path: file_path
        else
	  			f.update status: "success", desc: "成功"
	  		end
    	end
    else
    	f.update desc: "等待，前面有文件正在处理中"
    end	
	end

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
