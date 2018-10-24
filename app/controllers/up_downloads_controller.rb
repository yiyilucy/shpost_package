class UpDownloadsController < ApplicationController
  load_and_authorize_resource

  def index
    @up_downloads = initialize_grid(@up_downloads, order: 'created_at',order_direction: :desc)
     #@up_download = UpDownload.all
  end

  def show
    
  end

  def new
    #@up_download = UpDownload.new
    #respond_with(@up_download)
  end

  def edit
  end

  def create
      unless request.get?
        if !@up_download.name.empty?
          if file = upload_up_download(params[:file]['file'])       
        
            @up_download = UpDownload.new(up_download_params)
        
            @up_download.url = file
            @up_download.oper_date = Time.now.strftime("%Y-%m-%d %H:%m:%S")
            @up_download.save

            flash[:alert] = "上传成功"

            redirect_to up_downloads_url
          end 
        end 
      end
  end

  def update
    #@up_download.update(up_download_params)
    #respond_with(@up_download)
  end

  def destroy
    #@up_download.destroy
    #respond_with(@up_download)
    file_path = @up_download.url
    if File.exist?(file_path)
      File.delete(file_path)

      @up_download.destroy
    end
    respond_to do |format|
      format.html { redirect_to up_downloads_url }
      format.json { head :no_content }
    end
    
  end

  def to_import
    #redirect_to up_download_import_up_downloads_url
    @up_download = UpDownload.new
    render(:action => 'up_download_import')

  end

  def up_download_import
    unless request.get?
      if file = upload_up_download(params[:file]['file'])       
        
          @up_download = UpDownload.new(up_download_params)
        
          @up_download.url = file
          @up_download.oper_date = Time.now.strftime("%Y-%m-%d %H:%m:%S")
          @up_download.save
          flash[:alert] = "上传成功"

          
          redirect_to up_downloads_url
      end   
    end
  end

  def upload_up_download(file)
     if !file.original_filename.empty?
       direct = "#{Rails.root}/public/download/"
       
       if !File.exist?(direct)
           Dir.mkdir(direct)          
       end

       filename_before = file.original_filename[0,file.original_filename.rindex('.')]
       filename_after = file.original_filename.split('.').last
       filename = "#{Time.now.strftime("%Y-%m-%d %H:%m:%S")}_#{filename_before+'.'+filename_after}"
       # filename = "#{Time.now.strftime("%Y-%m-%d %H:%m:%S")}_#{file.original_filename}"

       file_path = direct + filename
       
       File.open(file_path, "wb") do |f|
          f.write(file.read)
       end
       file_path
     end
  end

  def up_download_export
    @up_download=UpDownload.find(params[:id])
    
    if @up_download.nil?
       flash[:alert] = "无此文档模板"
       redirect_to :action => 'index'
    else
       file_path = @up_download.url
        if File.exist?(file_path)
          io = File.open(file_path)
          filename_before = @up_download.url.split('/').last[0,@up_download.url.split('/').last.rindex('.')]
          filename_after = @up_download.url.split('.').last
          filename = filename_before + '.' + filename_after
          # send_data(io.read,:filename => @up_download.name,:type => "text/excel;charset=utf-8; header=present", disposition: 'attachment')
          # send_data(io.read,:filename => filename,:type => "application/octet-stream", disposition: 'attachment')
          send_data(io.read,:filename => filename,:type => "text/excel;charset=utf-8; header=present", disposition: 'attachment')
          io.close
        else
          redirect_to up_downloads_path, :notice => '模板不存在，下载失败！'
        end
    end
  end

  private
    def set_up_download
      @up_download = UpDownload.find(params[:id])
    end

    def up_download_params
      params.require(:up_download).permit(:name, :use, :desc, :ver_no)
      
    end
end