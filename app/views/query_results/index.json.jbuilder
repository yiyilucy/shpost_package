json.array!(@query_results) do |query_result|
  json.extract! query_result, :id
  json.url query_result_url(query_result, format: :json)
end
