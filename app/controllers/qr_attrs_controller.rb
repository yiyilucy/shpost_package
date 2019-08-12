class QrAttrsController < ApplicationController
  before_action :set_qr_attr, only: [:show, :edit, :update, :destroy]

  def index
    @qr_attrs = QrAttr.all
    respond_with(@qr_attrs)
  end

  def show
    respond_with(@qr_attr)
  end

  def new
    @qr_attr = QrAttr.new
    respond_with(@qr_attr)
  end

  def edit
  end

  def create
    @qr_attr = QrAttr.new(qr_attr_params)
    @qr_attr.save
    respond_with(@qr_attr)
  end

  def update
    @qr_attr.update(qr_attr_params)
    respond_with(@qr_attr)
  end

  def destroy
    @qr_attr.destroy
    respond_with(@qr_attr)
  end

  private
    def set_qr_attr
      @qr_attr = QrAttr.find(params[:id])
    end

    def qr_attr_params
      params[:qr_attr]
    end
end
