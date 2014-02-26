require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params

  attr_reader :params

  def initialize(req, route_params = {})
    @params = parse_www_encoded_form(req.query_string)
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)

  end

  def require(key)
  end

  def permitted?(key)
  end

  def to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  def parse_www_encoded_form(www_encoded_form)
    stuff = URI.decode_www_form(www_encoded_form)
    #hash = stuff.map{|thing| {thing[0] => thing[1]}}
    alf= stuff.map {|hash|[hash[0].gsub("]","").split("["),hash[1]]}
    alf.each{|m|m.flatten!}
    alf.map!{|array| hashizer(array)}
    @params = merger(alf)
  end

  def hashizer(array)
    return array[0] if array.count == 1
    {array.shift => hashizer(array)}
  end


  def deep_merge(hash1, hash2)
    merged = {}
    debugger
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

  def merger(array)
    return array if array.count == 1
    array[0] = deep_merge(array.shift, array[0])
    merger(array)
  end



  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
  end
end


