class ResultsController < ApplicationController
  before_action :allow_cors

  def index
    begin
      @news_result = News.new(params).aggregate
    rescue Elasticsearch::Transport::Transport::Errors::BadRequest => exception
      render json: {error: exception.message}, status: :unprocessable_entity
    end
  end

  private

  # Allow CORS from the frontend app; use rack-cors gem in real app
  def allow_cors
    headers['Access-Control-Allow-Origin'] = '*'
  end
end
