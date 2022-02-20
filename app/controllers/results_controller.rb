class ResultsController < ApplicationController
  before_action :allow_cors

  def index
    @news_result = News.new(params).aggregate
  end

  private

  def allow_cors
    headers['Access-Control-Allow-Origin'] = '*'
  end
end
