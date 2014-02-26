require 'URI'
require 'debugger'
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

data  =parse_www_encoded_form("user[address][street]=main&user[address][zip]=89436")
p data