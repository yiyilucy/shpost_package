class QueryResultImportFilesController < ApplicationController
  before_action :set_query_result_import_file, only: [:show, :edit, :update, :destroy]

  def index
    @query_result_import_files = QueryResultImportFile.all
    respond_with(@query_result_import_files)
  end

  def show
    respond_with(@query_result_import_file)
  end

  def new
    @query_result_import_file = QueryResultImportFile.new
    respond_with(@query_result_import_file)
  end

  def edit
  end

  def create
    @query_result_import_file = QueryResultImportFile.new(query_result_import_file_params)
    @query_result_import_file.save
    respond_with(@query_result_import_file)
  end

  def update
    @query_result_import_file.update(query_result_import_file_params)
    respond_with(@query_result_import_file)
  end

  def destroy
    @query_result_import_file.destroy
    respond_with(@query_result_import_file)
  end

  private
    def set_query_result_import_file
      @query_result_import_file = QueryResultImportFile.find(params[:id])
    end

    def query_result_import_file_params
      params[:query_result_import_file]
    end
end
