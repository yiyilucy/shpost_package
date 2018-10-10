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

  def import
    unless request.get?
      business_id = params[:business_select]

      if file = upload_info(params[:file]['file'], business_id)    
        ActiveRecord::Base.transaction do
          
          begin
            sheet_error = []
            rowarr = [] 
            instance=nil
            flash_message = ""

            if file.include?('.xlsx')
              instance= Roo::Excelx.new(file)
            elsif file.include?('.xls')
              instance= Roo::Excel.new(file)
            elsif file.include?('.csv')
              instance= Roo::CSV.new(file)
            end
            instance.default_sheet = instance.sheets.first
            title_row = instance.row(1)
            registration_no_index = title_row.index("挂号编号")
            postcode_index = title_row.index("邮编")
            current_line = nil

            # QueryResult.bulk_insert(:registration_no, :postcode, :order_date, :unit_id, :business_id, :source) do |query_result|
              
            2.upto(instance.last_row) do |line|

              current_line = line
              rowarr = instance.row(line)
              registration_no = rowarr[registration_no_index].blank? ? "" : rowarr[registration_no_index].to_s.gsub(' ','')
              postcode = rowarr[postcode_index].blank? ? "" : rowarr[postcode_index].to_s.gsub(' ','')

              if registration_no.blank?
                txt = "缺少挂号编号"
                sheet_error << (rowarr << txt << current_line)
                next
              end
              # if postcode.blank?
              #   txt = "缺少邮编"
              #   sheet_error << (rowarr << txt)
              #   next
              # end

              # info = QueryResult.find_by(registration_no: registration_no)
              
              # if info.blank?
                # query_result.add(registration_no: registration_no, postcode: postcode, order_date: Time.now, unit_id: current_user.unit.id, business_id: business_id, source: "邮政数据查询")
                # query_result.save!
                QueryResult.create! registration_no: registration_no, postcode: postcode, order_date: Time.now, unit_id: current_user.unit.id, business_id: business_id, source: "邮政数据查询"
              # else 
              #     info.update postcode: postcode
              # end
            end
            # end

            if !sheet_error.blank?
              flash_message = "导入失败！"
            else
              flash_message = "导入成功!"
            end
            flash[:notice] = flash_message

            if !sheet_error.blank?
              send_data(exporterrorinfos_xls_content_for(sheet_error,title_row),  
              :type => "text/excel;charset=utf-8; header=present",  
              :filename => "Error_Infos_#{Time.now.strftime("%Y%m%d")}.xls")  
            else
              redirect_to "/query_results/import"
            end

          rescue Exception => e
            flash[:alert] = e.message + "第" + current_line.to_s + "行"
            raise ActiveRecord::Rollback
          end
        end
      end
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

  private
    def set_query_result
      @query_result = QueryResult.find(params[:id])
    end

    def query_result_params
      params[:query_result]
    end

    def upload_info(file, business_id)
      if !file.original_filename.empty?
        direct = "#{Rails.root}/upload/info/"
        filename = "#{Time.now.to_f}_#{file.original_filename}"

        file_path = direct + filename
        File.open(file_path, "wb") do |f|
           f.write(file.read)
        end

        ImportFile.create! file_name: filename, file_path: file_path, import_date: Time.now, import_user: current_user.id, unit_id: current_user.unit.id, business_id: business_id

        file_path
      end
    end
end
