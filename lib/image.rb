
class Image

  def self.exists?(id)
    $redis.exists(id)
  end

  def self.delete(id)
    return unless $redis.exists(id)
    $redis.del "#{id}.original"
    $redis.del "#{id}.resized"
    $redis.del "#{id}"
  end
   
  def initialize(id)
    @data = { 'id' => id, 
              'original' => "/v1/image/#{id}/original",
              'resized' => "/v1/image/#{id}/resized" 
            }
    fetched = $redis.hgetall(id)
    @data.merge!(fetched)
  end

  def original
    $redis.get "#{@data['id']}.original"
  end

  def resized
    $redis.get "#{@data['id']}.resized"
  end

  def file_name
    @data['file_name']
  end

  def json_data
    @data.to_json
  end

end

