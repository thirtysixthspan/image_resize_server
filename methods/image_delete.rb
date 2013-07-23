delete %r{\A/v1/image/([0-9,a-f]{8}-[0-9,a-f]{4}-[0-9,a-f]{4}-[0-9,a-f]{4}-[0-9,a-f]{12})\z} do |id|
  content_type :json
  response = { 
    request_url: request.path_info, 
    request_method: request.request_method,
  }
  
  return 404 unless Image.exists?(id)
  Image.delete(id)

  response[:deleted] = true
  response[:status_message] = "File successfully removed" 
  [200, response.to_json]
end