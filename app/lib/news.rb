class News
  attr_reader :client, :filters, :interval

  # In params query, after and before can be empty. interval defaults to 1d if not present
  def initialize(params)
    # read url credentials and construct url in basic auth format
    url = "https://#{Rails.application.credentials.elasticsearch[:username]}:"+
      "#{Rails.application.credentials.elasticsearch[:password]}@#{Rails.application.credentials.elasticsearch[:url]}"
    # initialize elastic search client
    @client = Elasticsearch::Client.new url: url, log: false

    # assign interval if present or use 1d as default
    @interval = params[:interval].present? ? params[:interval] : '1d'

    query_filter_value = query_filter(params[:query])
    date_filter_value = date_filter(params[:after], params[:before])
    # add query and date filters to filter and remove any nil values
    @filters = [query_filter_value, date_filter_value].compact
  end

  # first aggregate by timestamp and then by medium with highest count on top on news index
  # size is zero because we only need aggregated result key and value
  # apply the filters boolean query to cache results
  # this method could throw an exception
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

  private

  # initialize query_filter only if query is present, otherwise the result will be empty from match filter
  # match query against the text key in document
  def query_filter(query)
    query_filter = nil

    if query.present?
      query_filter = {
        match: {
          text: query
        }
      }
    end

    query_filter
  end

  # check if either before or after values are present, other wise there is no need to create range filter
  def date_filter(after, before)
    date_filter = nil

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

    date_filter
  end
end
