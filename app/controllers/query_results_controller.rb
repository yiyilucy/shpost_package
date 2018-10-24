class QueryResultsController < ApplicationController
  load_and_authorize_resource

  def index
    @query_results = QueryResult.all
    respond_with(@query_results)
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    respond_to do |format|
      if @query_result.save
        format.html { redirect_to @query_results, notice: I18n.t('controller.create_success_notice', model: '信息') }
        format.json { render action: 'show', status: :created, location: @query_result }
      else
        format.html { render action: 'new' }
        format.json { render json: @query_result.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @query_result.update(query_result_params)
        format.html { redirect_to @query_result, notice: I18n.t('controller.update_success_notice', model: '信息')}
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @query_result.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @query_result.destroy
    respond_to do |format|
      format.html { redirect_to query_results_url }
      format.json { head :no_content }
    end
  end

  # def import
  #   unless request.get?
  #     business_id = params[:business_select]
  #     if params[:order_date].blank? or params[:order_date]["order_date"].blank?
  #       order_date=Time.now.strftime('%Y-%m-%d')
  #     else 
  #       order_date = to_date(params[:order_date]["order_date"])
  #     end

  #     if file = upload_info(params[:file]['file'], business_id, order_date)    
  #       ActiveRecord::Base.transaction do
          
  #         begin
  #           sheet_error = []
  #           rowarr = [] 
  #           instance=nil
  #           flash_message = ""

  #           if file.include?('.xlsx')
  #             instance= Roo::Excelx.new(file)
  #           elsif file.include?('.xls')
  #             instance= Roo::Excel.new(file)
  #           elsif file.include?('.csv')
  #             instance= Roo::CSV.new(file)
  #           end
  #           instance.default_sheet = instance.sheets.first
  #           title_row = instance.row(1)
  #           registration_no_index = title_row.index("挂号编号")
  #           postcode_index = title_row.index("邮编")
  #           current_line = nil

  #           # QueryResult.bulk_insert(:registration_no, :postcode, :order_date, :unit_id, :business_id, :source) do |query_result|
              
  #           2.upto(instance.last_row) do |line|

  #             current_line = line
  #             rowarr = instance.row(line)
  #             registration_no = rowarr[registration_no_index].blank? ? "" : rowarr[registration_no_index].to_s.gsub(' ','')
  #             postcode = rowarr[postcode_index].blank? ? "" : rowarr[postcode_index].to_s.gsub(' ','')

  #             if registration_no.blank?
  #               txt = "缺少挂号编号"
  #               sheet_error << (rowarr << txt << current_line)
  #               next
  #             end
  #             # if postcode.blank?
  #             #   txt = "缺少邮编"
  #             #   sheet_error << (rowarr << txt)
  #             #   next
  #             # end

  #             # info = QueryResult.find_by(registration_no: registration_no)
              
  #             # if info.blank?
  #               # query_result.add(registration_no: registration_no, postcode: postcode, order_date: Time.now, unit_id: current_user.unit.id, business_id: business_id, source: "邮政数据查询")
  #               # query_result.save!
  #               QueryResult.create! registration_no: registration_no, postcode: postcode, order_date: order_date, unit_id: current_user.unit.id, business_id: business_id, source: "邮政数据查询"
  #             # else 
  #             #     info.update postcode: postcode
  #             # end
  #           end
  #           # end

  #           if !sheet_error.blank?
  #             flash_message = "导入失败！"
  #           else
  #             flash_message = "导入成功!"
  #           end
  #           flash[:notice] = flash_message

  #           if !sheet_error.blank?
  #             send_data(exporterrorinfos_xls_content_for(sheet_error,title_row),  
  #             :type => "text/excel;charset=utf-8; header=present",  
  #             :filename => "Error_Infos_#{Time.now.strftime("%Y%m%d")}.xls")  
  #           else
  #             redirect_to "/query_results/import"
  #           end

  #         rescue Exception => e
  #           flash[:alert] = e.message + "第" + current_line.to_s + "行"
  #           raise ActiveRecord::Rollback
  #         end
  #       end
  #     end
  #   end
  # end

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

        if file = upload_info(params[:file]['file'], business_id, @order_date)    
          flash_message = "导入成功！"
        else
          flash_message = "导入失败!"
        end
      end
      flash[:notice] = flash_message

      redirect_to "/query_results/import"            
    end
  end



  def exporterrorinfos_xls_content_for(obj,title_row)
    xls_report = StringIO.new  
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
    book.write xls_report  
    xls_report.string  
  end


  def export
    @order_date = params[:order_date]
    @business_id=nil
    results = []
        
    if !@order_date.blank? and !params[:business].blank? and !params[:business]["business_id"].blank? 
      @business_id = params[:business]["business_id"]
      results << QueryResult.accessible_by(current_ability).where("order_date like ? and business_id = ? and status = ?", "#{@order_date}%", @business_id, "own").order(:registration_no)
      results << QueryResult.accessible_by(current_ability).where("order_date like ? and business_id = ? and status = ?", "#{@order_date}%", @business_id, "other").order(:registration_no)
      results << QueryResult.accessible_by(current_ability).where("order_date like ? and business_id = ? and status = ?","#{@order_date}%", @business_id, "unit").order(:registration_no)
      results << QueryResult.accessible_by(current_ability).where("order_date like ? and business_id = ? and status = ?", "#{@order_date}%", @business_id, "returns").order(:registration_no)
      results << QueryResult.accessible_by(current_ability).where("order_date like ? and business_id = ? and status = ?", "#{@order_date}%", @business_id, "waiting").order(:registration_no)
      QueryResult.accessible_by(current_ability).where("order_date like ? and business_id = ?", "#{@order_date}%", @business_id).update_all query_date: Time.now
    end
 
    send_data(results_xls_content_for(results), :type => "text/excel;charset=utf-8; header=present", :filename => "Results_#{Time.now.strftime("%Y%m%d")}.xls")        
  end

  def results_xls_content_for(objs)  
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet_name = ['本人收', '他人收', '单位收', '退件', '未妥投']
    
    i=0

    objs.each do |obj|
      sheet = book.create_worksheet :name => sheet_name[i]  
   
      blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
      sheet.row(0).default_format = blue  
  
      sheet.row(0).concat %w{邮政数据查询 挂号编号 邮件所属日期 查询日期 查询结果}  
      count_row = 1
      obj.each do |o|  
        sheet[count_row,0]="邮政数据查询"
        sheet[count_row,1]=o.registration_no
        sheet[count_row,2]=o.order_date.strftime('%Y-%m-%d').to_s
        sheet[count_row,3]=o.query_date.strftime('%Y-%m-%d').to_s
        sheet[count_row,4]=o.result.blank? ? "" : o.result
        
        count_row += 1
      end
      i += 1
    end  
  
    book.write xls_report  
    xls_report.string  
  end


  def query_result_index
    @start_date = DateTime
    @end_date = DateTime
    @business_id = nil
    @results = []
    @sum = 0
          
    if params[:end_date].blank? or params[:end_date]["end_date"].blank?
      @end_date = Time.now
    else 
      @end_date = to_date(params[:end_date]["end_date"])
    end

    if params[:start_date].blank? or params[:start_date]["start_date"].blank?
      # @start_date = Time.now.beginning_of_month.strftime('%Y-%m-%d')
      # @start_date = @end_date.days_ago(15)
      @start_date = Time.now
    else 
      @start_date = to_date(params[:start_date]["start_date"])
    end

    unless request.get?
      if (Date.parse(@end_date.strftime('%Y-%m-%d')) - Date.parse(@start_date.strftime('%Y-%m-%d'))).to_i > 15
        flash[:alert] = "日期间隔请勿超过15天"
        redirect_to :action => 'query_result_index'
      else
        if !params[:business].blank? and !params[:business]["business_id"].blank? 
          @business_id = params[:business]["business_id"]
          @results = QueryResult.accessible_by(current_ability).where("order_date >= ? and order_date <= ? and business_id = ?", @start_date, @end_date + 1.day, @business_id).group("order_date").group(:status).order("order_date, status").count
          @sum = QueryResult.accessible_by(current_ability).where("order_date >= ? and order_date <= ? and business_id = ?", @start_date, @end_date + 1.day, @business_id).group("order_date").order("order_date").count
        end
      end
    end
  end



  private
    def set_query_result
      @query_result = QueryResult.find(params[:id])
    end

    def query_result_params
      params[:query_result]
    end

    def upload_info(file, business_id, order_date)
      if !file.original_filename.empty?
        direct = "#{Rails.root}/upload/info/"
        filename = "#{Time.now.to_f}_#{file.original_filename}"

        file_path = direct + filename
        File.open(file_path, "wb") do |f|
           f.write(file.read)
        end

        ImportFile.create! file_name: filename, file_path: file_path, import_date: order_date, user_id: current_user.id, unit_id: current_user.unit.id, business_id: business_id

        file_path
      end
    end

    def to_date(time)
      date = Date.civil(time.split(/-|\//)[0].to_i,time.split(/-|\//)[1].to_i,time.split(/-|\//)[2].to_i)
      return date
    end
end
