class ResultsController < ApplicationController
  before_action :allow_cors

  def index
    begin
      @news_result = News.new(params).aggregate
    rescue Elasticsearch::Transport::Transport::Errors::BadRequest => exception
      @news_result = {error: exception}
    end
  end

  private

  def allow_cors
    headers['Access-Control-Allow-Origin'] = '*'
  end
end
