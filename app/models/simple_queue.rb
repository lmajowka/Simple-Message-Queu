class SimpleQueue

  def self.push(queue_url, item)
    $redis.rpush "simple_queue_system:#{queue_url}", encode(item)
  end

  def self.pop(queue_url)
    decode $redis.lpop("simple_queue_system:#{queue_url}")
  end

  private

  def self.encode(object)
    if MultiJson.respond_to?(:dump) && MultiJson.respond_to?(:load)
      MultiJson.dump object
    else
      MultiJson.encode object
    end
  end

  def self.decode(object)
    return unless object

    begin
      if MultiJson.respond_to?(:dump) && MultiJson.respond_to?(:load)
        MultiJson.load object
      else
        MultiJson.decode object
      end
    rescue ::MultiJson::DecodeError => e
      raise Helpers::DecodeException, e.message, e.backtrace
    end
  end

end