require_relative './hello_services_pb'

class HelloClient
  def initialize
    @client = Hello::Hello::Stub.new('localhost:8000', :this_channel_is_insecure)
  end

  def send_message(msg, client_stream: false, server_stream: false)
    if client_stream && server_stream
      m = Hello::HelloStreamRequest.new(msg: msg)
      @client.hello_stream(m)
    elsif client_stream
      m = Hello::HelloStreamRequest.new(msg: msg)
      @client.hello_client_stream(m)
    elsif server_stream
      m = Hello::HelloRequest.new(msg: msg)
      @client.hello_server_stream(m)
    else
      m = Hello::HelloRequest.new(msg: msg)
      @client.hello(m)
    end
  end
end
