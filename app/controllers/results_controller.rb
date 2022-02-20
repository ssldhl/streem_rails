class ResultsController < ApplicationController
  def index
    @news_result = News.new(params).aggregate
  end
end
