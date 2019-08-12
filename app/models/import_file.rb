class ImportFile < ActiveRecord::Base
	belongs_to :business
	belongs_to :unit
	belongs_to :user

	STATUS = { success: '成功', fail: '失败', waiting: '待处理', doing: '处理中'}
	IMPORT_TYPE = { QueryResult: '信息导入', ReturnResult: '退件导入'}
	
    def status_name
	  status.blank? ? "" : ImportFile::STATUS["#{status}".to_sym]
	end

	def import_type_name
	  import_type.blank? ? "" : ImportFile::IMPORT_TYPE["#{import_type}".to_sym]
	end

	def self.upload_info(file, business_id, order_date, import_type, current_user)
		if !file.original_filename.empty?
	      direct = "#{Rails.root}/upload/info/"
	      filename = "#{Time.now.to_f}_#{file.original_filename}"

	      file_path = direct + filename
	      File.open(file_path, "wb") do |f|
	        f.write(file.read)
	      end

	      ImportFile.create! file_name: filename, file_path: file_path, import_date: order_date, user_id: current_user.id, unit_id: current_user.unit.id, business_id: business_id, err_file_path: file_path, import_type: import_type

	      file_path
	    end
	end

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

	    if file = f.file_path
	      	ActiveRecord::Base.transaction do           
		        begin
		          f.update status: "doing"
		        rescue Exception => e
		          Rails.logger.error e.message 
		          raise ActiveRecord::Rollback
		        end
	      	end
      		ActiveRecord::Base.transaction do         
       			begin
		        	sheet_error = []
		          	rowarr = [] 
			        instance=nil
			        # Rails.logger.info "begin"
			        if file.include?('.xlsx')
			          instance= Roo::Excelx.new(file)
			        elsif file.include?('.xls')
			          instance= Roo::Excel.new(file)
			        elsif file.include?('.csv')
			          instance= Roo::CSV.new(file)
			        end
                
		          	# Rails.logger.info "File read: "+Time.now.strftime("%Y-%m-%d %H:%M:%S")
			        instance.default_sheet = instance.sheets.first
			        title_row = instance.row(1)
			        if !title_row.index("挂号编号").blank?
			          registration_no_index = title_row.index("挂号编号")
			        elsif !title_row.index("约投号码").blank?
			          registration_no_index = title_row.index("约投号码")
			        end
			        if !title_row.index("邮编").blank?
			          postcode_index = title_row.index("邮编")
			        end
			        if !title_row.index("数据日期").blank?
			          data_date_index = title_row.index("数据日期")
			        end
			        if !title_row.index("批次日期").blank?
			          batch_date_index = title_row.index("批次日期")
			        end
			        if !title_row.index("联名卡标识").blank?
			          lmk_index = title_row.index("联名卡标识")
			        end
			        if !title_row.index("识别码").blank?
			          id_code_index = title_row.index("识别码")
			        end
			        if !title_row.index("发卡行").blank?
			          issue_bank_index = title_row.index("发卡行")
			        end
			        if !title_row.index("姓名").blank?
			          name_index = title_row.index("姓名")
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
		                
		          	2.upto(instance.last_row) do |line|
		          		current_line = line
			            rowarr = instance.row(line)
			            registration_no = rowarr[registration_no_index].blank? ? "" : rowarr[registration_no_index].to_s.gsub(' ','')
			            postcode = rowarr[postcode_index].blank? ? "" : rowarr[postcode_index].to_s.split('.0')[0]

			            if registration_no.blank?
			              txt = "缺少挂号编号或约投号码" + "(第" + current_line.to_s + "行)"
			              sheet_error << (rowarr << txt)
			              next
			            end
		            	# Rails.logger.info "第" + current_line.to_s + "行, " + Time.now.strftime("%Y-%m-%d %H:%M:%S")
			            begin
			              if !title_row.index("联名卡标识").blank?
			              	data_date = rowarr[data_date_index].blank? ? nil : DateTime.parse(rowarr[data_date_index].to_s.split(".0")[0]).strftime('%Y-%m-%d')
			              	batch_date = rowarr[batch_date_index].blank? ? nil : DateTime.parse(rowarr[batch_date_index].to_s.split(".0")[0]).strftime('%Y-%m-%d')
			              	lmk = rowarr[lmk_index].blank? ? "" : rowarr[lmk_index].to_s.split('.0')[0]
			              	id_code = rowarr[id_code_index].blank? ? "" : rowarr[id_code_index].to_s.split('.0')[0]
			              	issue_bank = rowarr[issue_bank_index].blank? ? "" : rowarr[issue_bank_index].to_s.split('.0')[0]
			              	name = rowarr[name_index].blank? ? "" : rowarr[name_index].to_s.split('.0')[0]
			              	bank_no = rowarr[bank_no_index].blank? ? "" : rowarr[bank_no_index].to_s.split('.0')[0]
			              	phone = rowarr[phone_index].blank? ? "" : rowarr[phone_index].to_s.split('.0')[0]
			              	address = rowarr[address_index].blank? ? "" : rowarr[address_index].to_s.split('.0')[0]

			              	import_object = eval(f.import_type).find_by_registration_no registration_no
			              	
			              	if import_object.blank?
			              	  import_object = eval(f.import_type).create! registration_no: registration_no, postcode: postcode, order_date: f.import_date, unit_id: f.unit_id, business_id: f.business_id, source: "邮政数据查询", status: "waiting"
			              	  QrAttr.create! data_date: data_date, batch_date: batch_date, lmk: lmk, id_code: id_code, issue_bank: issue_bank, name: name, bank_no: bank_no, phone: phone, address: address, query_result_id: import_object.id
			              	else 
			              	  import_object.update postcode: postcode
			              	  import_object.qr_attr.update data_date: data_date, batch_date: batch_date, lmk: lmk, id_code: id_code, issue_bank: issue_bank, name: name, bank_no: bank_no, phone: phone, address: address
			              	end
			              else
			              	eval(f.import_type).create! registration_no: registration_no, postcode: postcode, order_date: f.import_date, unit_id: f.unit_id, business_id: f.business_id, source: "邮政数据查询", status: "waiting"
			              end
			            rescue ActiveRecord::RecordInvalid => e
			              txt = e.message + "(第" + current_line.to_s + "行)"
			              sheet_error << (rowarr << txt)
			              next
			            end

			            if current_line%1000 == 0
			              Rails.logger.info "*********** " + Time.now.strftime("%Y-%m-%d %H:%M:%S") + ", 文件<" + f.file_name + ">已处理到第" + current_line.to_s + "行 ***********"
			            end
		          	end
              
		          	if !sheet_error.blank?
			            filename = "Error_Infos_#{Time.now.strftime('%Y%m%d %H:%M:%S')}.xls"
			            file_path = direct + filename
			            
			            exporterrorinfos_xls_content_for(sheet_error, title_row, file_path)
			            f.update desc: "部分导入成功,#{sheet_error.size}行失败,可能原因是#{txt}", err_file_path: file_path
			        end

          		  	f.update status: "success"
                
		        rescue Exception => e
		          trans_error = true
		          message = e.message + "(第" + current_line.to_s + "行)"
		          Rails.logger.error e.message + "(第" + current_line.to_s + "行)"
		          raise ActiveRecord::Rollback
		        end
      		end
		    if trans_error
		      f.update status: "fail", desc: message
		    end
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
