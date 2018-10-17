class InterfaceSendersController < ApplicationController
  load_and_authorize_resource
  before_action :set_interface_sender, only: [:show, :edit, :update, :destroy]

  # GET /interface_senders
  # GET /interface_senders.json
  def index
    # @interface_senders = InterfaceSender.where("class_name is not null")
    @interface_senders_grid = initialize_grid(@interface_senders,
      :order => 'interface_senders.id',
      :order_direction => 'desc')
  end

  # GET /interface_senders/1
  # GET /interface_senders/1.json
  def show
  end

  # GET /interface_senders/new
  def new
    @interface_sender = InterfaceSender.new
  end

  # GET /interface_senders/1/edit
  def edit
  end

  # POST /interface_senders
  # POST /interface_senders.json
  def create
    @interface_sender = InterfaceSender.new(interface_sender_params)

    respond_to do |format|
      if @interface_sender.save
        format.html { redirect_to @interface_sender, notice: 'Interface info was successfully created.' }
        format.json { render action: 'show', status: :created, location: @interface_sender }
      else
        format.html { render action: 'new' }
        format.json { render json: @interface_sender.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /interface_senders/1
  # PATCH/PUT /interface_senders/1.json
  def update
    respond_to do |format|
      if @interface_sender.update(interface_sender_params)
        format.html { redirect_to @interface_sender, notice: 'Interface info was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @interface_sender.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /interface_senders/1
  # DELETE /interface_senders/1.json
  def destroy
    @interface_sender.destroy
    respond_to do |format|
      format.html { redirect_to interface_senders_url }
      format.json { head :no_content }
    end
  end

  def rebuild
    respond_to do |format|
      result = @interface_sender.interface_rebuild
      if result
        
        format.html { redirect_to action: 'index' }
        format.json { head :no_content }
      else
        # @interface_senders = InterfaceSender.all
        # @interface_senders_grid = initialize_grid(@interface_senders)
        format.html { redirect_to action: 'index' }
        format.json { head :no_content }
      end
    end
  end

  def resend
    respond_to do |format|
      result = @interface_sender.interface_send
      if result
        
        format.html { redirect_to action: 'index' }
        format.json { head :no_content }
      else
        # @interface_senders = InterfaceSender.all
        # @interface_senders_grid = initialize_grid(@interface_senders)
        format.html { redirect_to action: 'index' }
        format.json { head :no_content }
      end
    end
  end

  def show_error
    @object_name = ""
    if !@interface_sender.object_class.blank? && !@interface_sender.object_id.blank?
      begin
        o = @interface_sender.object_class.constantize
        object = o.find_by id: @interface_sender.object_id
        if !object.barcode.blank?
          @object_name = object.barcode
        end
      rescue Exception => e
        @object_name = ""
      end
    end
  end

  def all_resend
    interface_senders = InterfaceSender.where(storage_id:current_storage,status:"failed").where("interface_senders.created_at >= '#{DateTime.parse((Time.now-1.month).to_s).strftime('%Y-%m-%d').to_s}' and interface_senders.created_at<= '#{DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d').to_s}'")
    
    if !interface_senders.blank?
      interface_senders.update_all(status:"waiting",next_time:Time.now)
    end
    redirect_to action: 'index'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_interface_sender
      @interface_sender = InterfaceSender.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def interface_sender_params
      params.require(:interface_sender).permit(:method_name, :class_name, :status, :operate_time, :url, :url_method, :url_content, :type)
    end
end
