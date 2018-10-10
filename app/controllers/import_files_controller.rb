class ImportFilesController < ApplicationController
  before_action :set_import_file, only: [:show, :edit, :update, :destroy]

  def index
    @import_files = ImportFile.all
    respond_with(@import_files)
  end

  def show
    respond_with(@import_file)
  end

  def new
    @import_file = ImportFile.new
    respond_with(@import_file)
  end

  def edit
  end

  def create
    @import_file = ImportFile.new(import_file_params)
    @import_file.save
    respond_with(@import_file)
  end

  def update
    @import_file.update(import_file_params)
    respond_with(@import_file)
  end

  def destroy
    @import_file.destroy
    respond_with(@import_file)
  end

  private
    def set_import_file
      @import_file = ImportFile.find(params[:id])
    end

    def import_file_params
      params[:import_file]
    end
end
