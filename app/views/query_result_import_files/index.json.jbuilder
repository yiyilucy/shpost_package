json.array!(@query_result_import_files) do |query_result_import_file|
  json.extract! query_result_import_file, :id
  json.url query_result_import_file_url(query_result_import_file, format: :json)
end
