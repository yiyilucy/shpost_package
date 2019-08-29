class ReturnReasonsController < ApplicationController
  load_and_authorize_resource

  def index
    @return_reasons_grid = initialize_grid(@return_reasons)
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    respond_to do |format|
      if @return_reason.save
        format.html { redirect_to return_reasons_url, notice: I18n.t('controller.create_success_notice', model: '退件理由') }
        format.json { head :no_content }
      else
        format.html { render action: 'new' }
        format.json { render json: @return_reason.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @return_reason.update(return_reason_params)
        format.html { redirect_to return_reasons_url, notice: I18n.t('controller.update_success_notice', model: '退件理由')}
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @return_reason.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @return_reason.destroy
    respond_to do |format|
      format.html { redirect_to return_reasons_url }
      format.json { head :no_content }
    end
  end

  private
    def set_return_reason
      @return_reason = ReturnReason.find(params[:id])
    end

    def return_reason_params
      params.require(:return_reason).permit(:reason, :unit_id)
    end
end
