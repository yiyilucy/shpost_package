class UnitsController < ApplicationController
  load_and_authorize_resource :unit

  # GET /units
  # GET /units.json
  def index
    #@unit = Unit.all
    @units_grid = initialize_grid(@units)
  end

  # GET /units/1
  # GET /units/1.json
  def show
  end

  # GET /units/new
  def new
    #@unit = Unit.new
  end

  # GET /units/1/edit
  def edit
  end

  # POST /units
  # POST /units.json
  def create
    respond_to do |format|
      if @unit.save
        format.html { redirect_to @unit, notice: I18n.t('controller.create_success_notice', model: '单位')}
        format.json { render action: 'show', status: :created, location: @unit }
      else
        format.html { render action: 'new' }
        format.json { render json: @unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    respond_to do |format|
      if @unit.update(unit_params)
        format.html { redirect_to @unit, notice: I18n.t('controller.update_success_notice', model: '单位') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @unit.destroy
    respond_to do |format|
      format.html { redirect_to units_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    #def set_unit
      #@unit = Unit.find(params[:id])
    #end

    # Never trust parameters from the scary internet, only allow the white list through.
    def unit_params
      params.require(:unit).permit(:no, :name, :desc, :short_name, :tcbd_khdh, :unit_level, :parent_id)
    end
end
