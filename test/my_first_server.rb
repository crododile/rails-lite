require 'webrick'

root = "/"

server = WEBrick::HTTPServer.new :Port  => 8000, :DocumentRoot => root



server.mount_proc '/' do |req, res|
  res.content_type=('text')
  res.body = req
end

trap('INT') {server.shutdown}

server.start