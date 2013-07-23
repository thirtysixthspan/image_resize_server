require File.join(File.dirname(__FILE__), '..', 'main.rb')

require 'sinatra'
require 'rest_client'
require 'rspec'

describe "image" do
  
  def app
    Sinatra::Application
  end  

  def upload_test_image
    file = File.open("./spec/testimage.jpeg", "rb")
    query = { 
      image_name: 'testimage.jpeg', 
      data: file, 
      resized_width: 100, 
      resized_height: 100 
    }
    RestClient.post("http://0.0.0.0:5000/v1/image", query)
  end

  before(:all) do
    @response = upload_test_image()
    @response.code.should == 200
    @uploaded_image = JSON.parse(@response.body)
    $id = @uploaded_image['id'] 
  end

  it "should accept an uploaded image and assign a unique id" do
    @uploaded_image.should include 'id'
    @uploaded_image.should include 'original'
    @uploaded_image.should include 'resized'
  end

  it "should provide image metadata" do
    response = RestClient.get("http://0.0.0.0:5000/v1/image/#{$id}")
    response.code.should == 200
    image = JSON.parse(response.body) 
    image.should include 'id'
    image.should include 'original'
    image.should include 'resized'
    image.should include 'resized_width'
    image.should include 'resized_height'
    image.should include 'uploaded_at'
  end

  it "should return a previously uploaded image" do
    response = RestClient.get("http://0.0.0.0:5000/v1/image/#{$id}/original")
    response.code.should == 200
    response.body.size.should == 63194
  end

  it "should return the resized version of a previously uploaded image" do
    response = RestClient.get("http://0.0.0.0:5000/v1/image/#{$id}/resized")
    response.code.should == 200
    response.body.size.should == 3593
  end

  it "should delete images upon request" do
    response = RestClient.get("http://0.0.0.0:5000/v1/image/#{$id}")
    response.code.should == 200

    response = RestClient.delete("http://0.0.0.0:5000/v1/image/#{$id}")
    response.code.should == 200

    RestClient.get("http://0.0.0.0:5000/v1/image/#{$id}") do |response|
      response.code.should == 404
    end

    RestClient.get("http://0.0.0.0:5000/v1/image/#{$id}/original") do |response|
      response.code.should == 404
    end

    RestClient.get("http://0.0.0.0:5000/v1/image/#{$id}/resized") do |response|
      response.code.should == 404
    end

  end

end

