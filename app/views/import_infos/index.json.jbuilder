json.array!(@import_infos) do |import_info|
  json.extract! import_info, :id
  json.url import_info_url(import_info, format: :json)
end
