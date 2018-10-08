json.array!(@units) do |unit|
  json.extract! unit, :id, :name, :desc, :short_name
  json.url unit_url(unit, format: :json)
end
