class ReturnResultsController < ApplicationController
	load_and_authorize_resource

	def import
	    @order_date = Time.now.strftime('%Y-%m-%d')
	    unless request.get?
	      business_id = params[:business_select]
	      if business_id.blank?
	        flash_message = "请选择商户！"
	      else
	        if !params[:order_date].blank? and !params[:order_date]["order_date"].blank?
	          @order_date = to_date(params[:order_date]["order_date"])
	        end

	        if file = ImportFile.upload_info(params[:file]['file'], business_id, @order_date, "ReturnResult", current_user)    
	          flash_message = "导入成功！"
	        else
	          flash_message = "导入失败!"
	        end
	      end
	      flash[:notice] = flash_message

	      redirect_to "/return_results/import"            
	    end
	end

	def return_result_index
	    @start_date=DateTime
    	@end_date=DateTime
	    @business_id = nil
	    @results = []
	    @sum = 0
	    groupQuery = ""

	    if !params[:start_date].blank? and !params[:start_date]["start_date"].blank?
	      @start_date = to_date(params[:start_date]["start_date"])
	    else
	      @start_date = 1.month.ago
	    end
	    if !params[:end_date].blank? and !params[:end_date]["end_date"].blank?
	      @end_date = to_date(params[:end_date]["end_date"])
	    else
	      @end_date = Time.now
	    end
          
	    if !@start_date.blank? and !@end_date.blank?
	        unless request.get?
		      	if !params[:business].blank? and !params[:business]["business_id"].blank? 
			        @business_id = params[:business]["business_id"]
			        if RailsEnv.is_oracle?
				      groupQuery = "to_char(return_results.order_date,'yyyy-mm-dd')"
				    else
				      groupQuery = "strftime('%Y-%m-%d',return_results.order_date)"
				    end
			        @results = ReturnResult.accessible_by(current_ability).where("order_date >= ? and order_date <= ? and business_id = ?", @start_date, @end_date+1.day, @business_id).group(groupQuery).group(:status).order("order_date, status").count
			        @sum = ReturnResult.accessible_by(current_ability).where("order_date >= ? and order_date <= ? and business_id = ?", @start_date, @end_date+1.day, @business_id).group(groupQuery).order("order_date").count
			        @sum_all = ReturnResult.accessible_by(current_ability).where("order_date >= ? and order_date <= ? and business_id = ?", @start_date, @end_date+1.day, @business_id).count
			        @normal_all = ReturnResult.accessible_by(current_ability).where("order_date >= ? and order_date <= ? and business_id = ? and status = ?", @start_date, @end_date+1.day, @business_id, "normal").count
			        @signed_all = ReturnResult.accessible_by(current_ability).where("order_date >= ? and order_date <= ? and business_id = ? and status = ?", @start_date, @end_date+1.day, @business_id, "signed").count
			        @others_all = ReturnResult.accessible_by(current_ability).where("order_date >= ? and order_date <= ? and business_id = ? and status = ?", @start_date, @end_date+1.day, @business_id, "others").count
			        @waiting_all = ReturnResult.accessible_by(current_ability).where("order_date >= ? and order_date <= ? and business_id = ? and status = ?", @start_date, @end_date+1.day, @business_id, "waiting").count
			    end
		    end
		end
	end

  	def export
	    @order_date = params[:order_date]
	    @business_id=nil
	    results = []
	    is_abc =false

	    if !params[:checkbox].blank? and !params[:checkbox][:is_abc].blank? 
	      is_abc = (params[:checkbox][:is_abc].eql?"1") ? true : false
	    end
        
	    if !@order_date.blank? and !params[:business].blank? and !params[:business]["business_id"].blank? 
	      @business_id = params[:business]["business_id"]

	      if is_abc
	      	results = ReturnResult.accessible_by(current_ability).joins(:query_result).joins({query_result: :qr_attr}).where("return_results.order_date like ? and return_results.business_id = ?", "#{@order_date}%", @business_id).order("qr_attrs.batch_date, return_results.registration_no")
	      else
		      results << ReturnResult.accessible_by(current_ability).where("order_date like ? and business_id = ? and status = ?", "#{@order_date}%", @business_id, "normal").order(:registration_no)
		      results << ReturnResult.accessible_by(current_ability).where("order_date like ? and business_id = ? and status = ?", "#{@order_date}%", @business_id, "signed").order(:registration_no)
		      results << ReturnResult.accessible_by(current_ability).where("order_date like ? and business_id = ? and status = ?","#{@order_date}%", @business_id, "others").order(:registration_no)
		      results << ReturnResult.accessible_by(current_ability).where("order_date like ? and business_id = ? and status = ?", "#{@order_date}%", @business_id, "waiting").order(:registration_no)
		  end
	      ReturnResult.accessible_by(current_ability).where("order_date like ? and business_id = ?", "#{@order_date}%", @business_id).update_all query_date: Time.now
	    end
 		
 		if is_abc
 			send_data(results_abc_xls_content_for(results), :type => "text/excel;charset=utf-8; header=present", :filename => "Results_ABC_#{Time.now.strftime("%Y%m%d")}.xls")
 		else
    		send_data(results_xls_content_for(results), :type => "text/excel;charset=utf-8; header=present", :filename => "Results_#{Time.now.strftime("%Y%m%d")}.xls")    
    	end    
  	end

  	def results_xls_content_for(objs)  
	    xls_report = StringIO.new  
	    book = Spreadsheet::Workbook.new  
	    sheet_name = ['普通退件', '签收后退件', '异常退件', '待查询']
	    
	    i=0

	    objs.each do |obj|
	      sheet = book.create_worksheet :name => sheet_name[i]  
	   
	      blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
	      sheet.row(0).default_format = blue  
	  
	  	  if sheet_name[i].eql?"签收后退件"
	      	sheet.row(0).concat %w{邮政数据查询 挂号编号 邮件所属日期 查询日期 签收描述 签收时间} 
	      else
	      	sheet.row(0).concat %w{邮政数据查询 挂号编号 邮件所属日期 查询日期}
	      end
	      count_row = 1
	      obj.each do |o|  
	        sheet[count_row,0]="邮政数据查询"
	        sheet[count_row,1]=o.registration_no
	        sheet[count_row,2]=o.order_date.strftime('%Y-%m-%d').to_s
	        sheet[count_row,3]=o.query_date.strftime('%Y-%m-%d').to_s
	        if sheet_name[i].eql?"签收后退件"
		        sheet[count_row,4]=o.result.blank? ? "" : o.result
		        sheet[count_row,5]=o.operated_at.blank? ? "" : o.operated_at.strftime('%Y-%m-%d').to_s
		    end
	        
	        count_row += 1
	      end
	      i += 1
	    end  
	  
	    book.write xls_report  
	    xls_report.string  
 	end

 	def results_abc_xls_content_for(obj)
	    xls_report = StringIO.new  
	    book = Spreadsheet::Workbook.new  
	    sheet1 = book.create_worksheet :name => "Results_ABC"  

	    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
	    sheet1.row(0).default_format = blue 
	    sheet1.row(0).concat %w{邮编 姓名 电话 地址 批次日期 约投号码 退回原因}  
	    count_row = 1
	    obj.each do |obj|
	      sheet1[count_row,0]=obj.postcode
	      sheet1[count_row,1]=obj.query_result.qr_attr.name
	      sheet1[count_row,2]=obj.query_result.qr_attr.phone
	      sheet1[count_row,3]=obj.query_result.qr_attr.address
	      sheet1[count_row,4]=obj.query_result.qr_attr.batch_date.strftime("%Y-%m-%d").to_s
	      sheet1[count_row,5]=obj.registration_no
	      sheet1[count_row,6]=obj.reason
	      
	      count_row += 1
	    end 
	    book.write xls_report  
	    xls_report.string  
	end

	private
		def to_date(time)
	      date = Date.civil(time.split(/-|\//)[0].to_i,time.split(/-|\//)[1].to_i,time.split(/-|\//)[2].to_i)
	      return date
	    end

end
