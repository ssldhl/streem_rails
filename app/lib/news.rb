class News
  attr_reader :client, :filters, :interval

  # In params query, after and before can be empty. interval defaults to 1d if not present
  def initialize(params)
    url = "https://#{Rails.application.credentials.elasticsearch[:username]}:"+
      "#{Rails.application.credentials.elasticsearch[:password]}@#{Rails.application.credentials.elasticsearch[:url]}"
    query_filter = nil
    date_filter = nil

    if params[:query].present?
      query_filter = {
        match: {
          text: params[:query]
        }
      }
    end

    if params[:after].present? || params[:before].present?
      date_filter = {
        range: {
          timestamp: {
            format: 'epoch_second'
          }
        }
      }
      if params[:after].present?
        date_filter[:range][:timestamp][:gte] = params[:after]
      end
      if params[:before].present?
        date_filter[:range][:timestamp][:lte] = params[:before]
      end
    end

    @client = Elasticsearch::Client.new url: url, log: false
    @filters = [query_filter, date_filter].compact
    @interval = params[:interval].present? ? params[:interval] : '1d'
  end

  def aggregate
    client.search index: 'news', body: {
      aggs: {
        first_agg: {
          date_histogram: {
            field: 'timestamp',
            calendar_interval: interval,
            time_zone: 'Australia/Sydney'
          },
          aggs: {
            second_agg: {
              terms: {
                field: 'medium',
                order: {
                  _count: 'desc'
                }
              }
            }
          }
        }
      },
      size: 0,
      query: {
        bool: {
          filter: filters
        }
      }
    }
  end
end
