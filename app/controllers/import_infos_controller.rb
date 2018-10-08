class ImportInfosController < ApplicationController
  load_and_authorize_resource

  def index
    @import_infos = ImportInfo.all
    @import_infos_grid = initialize_grid(@import_infos, order: 'import_infos.created_at',
      order_direction: 'desc')
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    respond_to do |format|
      if @import_info.save
        format.html { redirect_to @import_infos, notice: I18n.t('controller.create_success_notice', model: '信息') }
        format.json { render action: 'show', status: :created, location: @import_info }
      else
        format.html { render action: 'new' }
        format.json { render json: @import_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @import_info.update(import_info_params)
        format.html { redirect_to @import_info, notice: I18n.t('controller.update_success_notice', model: '信息')}
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @import_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @import_info.destroy
    respond_to do |format|
      format.html { redirect_to import_infos_url }
      format.json { head :no_content }
    end
  end

  def import
    unless request.get?
      if file = upload_info(params[:file]['file'])    
        ActiveRecord::Base.transaction do
          begin
            sheet_error = []
            rowarr = [] 
            instance=nil
            flash_message = "导入成功!"

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

            2.upto(instance.last_row) do |line|
              current_line = line
              rowarr = instance.row(line)
              registration_no = rowarr[registration_no_index].blank? ? "" : rowarr[registration_no_index].to_s.gsub(' ','')
              postcode = rowarr[postcode_index].blank? ? "" : rowarr[postcode_index].to_s.gsub(' ','')

              if registration_no.blank?
                txt = "缺少挂号编号"
                sheet_error << (rowarr << txt)
                next
              end
              if postcode.blank?
                txt = "缺少邮编"
                sheet_error << (rowarr << txt)
                next
              end

              info = ImportInfo.find_by(registration_no: registration_no)
              
              if info.blank?
                ImportInfo.create! registration_no: registration_no, postcode: postcode
              else
                info.update postcode: postcode
              end
            end

            if !sheet_error.blank?
              flash_message << "有部分信息导入失败！"
            end
            flash[:notice] = flash_message

            if !sheet_error.blank?
              send_data(exporterrorinfos_xls_content_for(sheet_error,title_row),  
              :type => "text/excel;charset=utf-8; header=present",  
              :filename => "Error_Infos_#{Time.now.strftime("%Y%m%d")}.xls")  
            else
              redirect_to "/import_infos/import"
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
    def set_import_info
      @import_info = ImportInfo.find(params[:id])
    end

    def import_info_params
      params[:import_info]
    end

    def upload_info(file)
      if !file.original_filename.empty?
        direct = "#{Rails.root}/upload/info/"
        filename = "#{Time.now.to_f}_#{file.original_filename}"

        file_path = direct + filename
        File.open(file_path, "wb") do |f|
           f.write(file.read)
        end
        file_path
      end
    end
end
