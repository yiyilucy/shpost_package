class QueryResultsController < ApplicationController
  before_action :set_query_result, only: [:show, :edit, :update, :destroy]

  def index
    @query_results = QueryResult.all
    respond_with(@query_results)
  end

  def show
    respond_with(@query_result)
  end

  def new
    @query_result = QueryResult.new
    respond_with(@query_result)
  end

  def edit
  end

  def create
    @query_result = QueryResult.new(query_result_params)
    @query_result.save
    respond_with(@query_result)
  end

  def update
    @query_result.update(query_result_params)
    respond_with(@query_result)
  end

  def destroy
    @query_result.destroy
    respond_with(@query_result)
  end

  private
    def set_query_result
      @query_result = QueryResult.find(params[:id])
    end

    def query_result_params
      params[:query_result]
    end
end
