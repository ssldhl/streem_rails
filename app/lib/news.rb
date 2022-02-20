class News
  attr_reader :client, :filters, :interval

  # query, after and before can be empty. interval defaults to 1d if not present
  def initialize(query, after, before, interval)
    url = "https://#{Rails.application.credentials.elasticsearch[:username]}:"+
      "#{Rails.application.credentials.elasticsearch[:password]}@#{Rails.application.credentials.elasticsearch[:url]}"
    query_filter = nil
    date_filter = nil

    if query.present?
      query_filter = {
        match: {
          text: query
        }
      }
    end

    if after.present? || before.present?
      date_filter = {
        range: {
          timestamp: {
            format: 'epoch_second'
          }
        }
      }
      if after.present?
        date_filter[:range][:timestamp][:gte] = after
      end
      if before.present?
        date_filter[:range][:timestamp][:lte] = before
      end
    end

    @client = Elasticsearch::Client.new url: url
    @filters = [query_filter, date_filter].compact
    @interval = interval.present? ? interval : '1d'
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
