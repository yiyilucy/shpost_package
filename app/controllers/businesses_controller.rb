class BusinessesController < ApplicationController
  load_and_authorize_resource

  def index
    @businesses_grid = initialize_grid(@businesses,
         :order => 'businesses.id',
         :order_direction => 'asc')
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    respond_to do |format|
      if @business.save
        format.html { redirect_to @business, notice: I18n.t('controller.create_success_notice', model: '商户') }
        format.json { render action: 'show', status: :created, location: @business }
      else
        format.html { render action: 'new' }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @business.update(business_params)
        format.html { redirect_to @business, notice: I18n.t('controller.update_success_notice', model: '商户')}
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @business.destroy
    respond_to do |format|
      format.html { redirect_to businesses_url }
      format.json { head :no_content }
    end
  end

  private
    def set_business
      @business = Business.find(params[:id])
    end

    def business_params
      params.require(:business).permit(:name, :start_date, :end_date, :unit_id, :keep_days)
    end
end
