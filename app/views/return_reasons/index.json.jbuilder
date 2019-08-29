json.array!(@return_reasons) do |return_reason|
  json.extract! return_reason, :id
  json.url return_reason_url(return_reason, format: :json)
end
