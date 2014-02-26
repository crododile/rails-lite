require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params

  attr_reader :params

  def initialize(req, route_params = {})
    @params=route_params
    if req.query_string
      @params.merge(parse_www_encoded_form(req.query_string))
    end
    if req.body
      @params.merge(parse_www_encoded_form(req.body))
    end
  end

  def [](key)
   return @params[key] if @params[key]
   @params[@params.keys.first].[](key)
  end

  def permit(*keys)

  end

  def require(key)
    params[key]
  end

  def permitted?(key)
  end

  def to_s
  end

  private
  def parse_www_encoded_form(www_encoded_form)
    @params = merger( parse_key(www_encoded_form)
                    .map!{|array| hashizer(array)} )[0]
  end

  def hashizer(array)
    return array[0] if array.count == 1
    {array.shift => hashizer(array)}
  end

  def merger(array)
    return array if array.count == 1
    array[0] = deep_merge(array.shift, array[0])
    merger(array)
  end

  def deep_merge(hash1, hash2)
    merged = {}

    shared_keys = hash1.keys & hash2.keys
    shared_keys.each do |key|
      merged[key] = deep_merge(hash1[key], hash2[key])
    end

    [hash1, hash2].each do |hash|
      (hash.keys - shared_keys).each do |key|
        merged[key] = hash[key]
      end
    end
    merged
  end

  def parse_key(key)
    URI.decode_www_form(key)
    .map{|hash|[hash[0].gsub("]","").split("["),hash[1]]}
    .each{|m|m.flatten!}
  end
end


