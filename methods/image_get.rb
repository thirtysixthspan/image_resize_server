get %r{\A/v1/image/([0-9,a-f]{8}-[0-9,a-f]{4}-[0-9,a-f]{4}-[0-9,a-f]{4}-[0-9,a-f]{12})\z} do |id|
  return 404 unless Image.exists?(id)
  image = Image.new(id)
  content_type :json
  [200, image.json_data]
end


get %r{\A/v1/image/([0-9,a-f]{8}-[0-9,a-f]{4}-[0-9,a-f]{4}-[0-9,a-f]{4}-[0-9,a-f]{12})/(.*?)\z} do |id,image_type|
  return 404 unless Image.exists?(id)
  image = Image.new(id)
  headers = {
    'Content-Disposition' => "filename=#{image.file_name}",
    'Cache-Control' => "public, max-age=#{24*60*60}, must-revalidate"
  }
  [200, headers, image.send(image_type)]
end



