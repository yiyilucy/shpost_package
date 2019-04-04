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
			        else
			          registration_no_index = 2
			        end
			        if !title_row.index("邮编").blank?
			          postcode_index = title_row.index("邮编")
			        else
			          postcode_index = 4
			        end
		                

		          	2.upto(instance.last_row) do |line|
			            current_line = line
			            rowarr = instance.row(line)
			            registration_no = rowarr[registration_no_index].blank? ? "" : rowarr[registration_no_index].to_s.gsub(' ','')
			            postcode = rowarr[postcode_index].blank? ? "" : rowarr[postcode_index].to_s.gsub(' ','')

			            if registration_no.blank?
			              txt = "缺少挂号编号" + "(第" + current_line.to_s + "行)"
			              sheet_error << (rowarr << txt)
			              next
			            end
		            	# Rails.logger.info "第" + current_line.to_s + "行, " + Time.now.strftime("%Y-%m-%d %H:%M:%S")
			            begin
			              eval(f.import_type).create! registration_no: registration_no, postcode: postcode, order_date: f.import_date, unit_id: f.unit_id, business_id: f.business_id, source: "邮政数据查询"
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

  	def exporterrorinfos_xls_content_for(obj,title_row,file_path)
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
