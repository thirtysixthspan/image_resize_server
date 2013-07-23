require 'sinatra'
require 'rack/contrib'
require 'redis'
require 'uuidtools'
require 'json'
require 'sanitize'

require './lib/helpers.rb'
require './lib/image.rb'

require './methods/image_post'
require './methods/image_get'
require './methods/image_delete'

error do
  content_type :json
  [ 
    500, 
    {  
      status: 500,
      message: request.env['sinatra.error'].message,
    }.to_json 
  ]
end

get '*' do
  content_type :json
  [ 404, 
    {
      status: 404,
      message: "not found"
    }.to_json 
  ]
end


