json.array!(@import_files) do |import_file|
  json.extract! import_file, :id
  json.url import_file_url(import_file, format: :json)
end
