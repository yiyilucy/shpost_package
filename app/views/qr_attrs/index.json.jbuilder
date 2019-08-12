json.array!(@qr_attrs) do |qr_attr|
  json.extract! qr_attr, :id
  json.url qr_attr_url(qr_attr, format: :json)
end
