json.array!(@businesses) do |business|
  json.extract! business, :name, :start_date, :end_date, :unit_id
  json.url business_url(business, format: :json)
end
