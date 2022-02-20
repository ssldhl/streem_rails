if @news_result[:error].present?
  json.result @news_result
else
  json.result @news_result
end
