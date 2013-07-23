post '/v1/image' do
  content_type :json
  response = { 
    request_url: request.path_info, 
    request_method: request.request_method 
  }
  required_params = ['image_name', 'resized_width', 'resized_height']
  cleared_params = ['data']
  success, response[:status_message], validated_params = validate(params, required_params, cleared_params)
  return [400, response.to_json] unless success

  width = validated_params['resized_width'].to_i
  height = validated_params['resized_height'].to_i
  if (width<1 || width>2000 || height<1 || height>2000) 
    return [400, response.to_json] 
  end

  image_id = UUIDTools::UUID.random_create.to_s

  image = {        
    'id' => image_id,
    'uploaded_at' => Time.now.to_i
  } 
  required_params.each { |rp| image[rp] = params[rp] }
  
  if $redis.mapped_hmset(image_id, image) != "OK"
    response[:status_message] = "Unable to complete request"
    return [500, response.to_json]     
  end

  if !params[:data].kind_of?(Hash) || !params[:data].include?(:tempfile)
    response[:status_message] = 'Failed to receive image'
    return [406, response.to_json] 
  end

  file = File.open(params[:data][:tempfile],'rb')
  if $redis.set("#{image_id}.original", file.read) != "OK"
    response[:status_message] = "Unable to complete request"
    return [500, response.to_json]     
  end

  resized = Tempfile.new('thumb')
  `convert -geometry #{width}x#{height} #{params[:data][:tempfile].path} #{resized.path}`
  resized.close

  file = File.open(resized.path,'rb')
  if $redis.set("#{image_id}.resized", file.read) != "OK"
    response[:status_message] = "Unable to complete request"
    return [500, response.to_json]     
  end

  resized.unlink
  
  response[:id] = image_id
  response[:original] = "/image/#{image_id}"
  response[:resized] = "/image/#{image_id}/resized"
  response[:status_message] = "Upload success" 
  [200, response.to_json]
end
