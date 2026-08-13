require_relative './hello_services_pb'

class HelloClient
  def initialize(host = 'localhost:8000')
    @client = Hello::Hello::Stub.new(host, :this_channel_is_insecure)
  end

  def send_message(msg, client_stream: false, server_stream: false, metadata: {}, timeout: 0.1)
    options = { metadata: metadata }
    options[:deadline] = Time.now + timeout if timeout

    if client_stream && server_stream
      m = Hello::HelloStreamRequest.new(msg: msg)
      @client.hello_stream([m].to_enum, **options)
    elsif client_stream
      m = Hello::HelloStreamRequest.new(msg: msg)
      @client.hello_client_stream([m].to_enum, **options)
    elsif server_stream
      m = Hello::HelloRequest.new(msg: msg)
      @client.hello_server_stream(m, **options)
    else
      m = Hello::HelloRequest.new(msg: msg)
      @client.hello(m, **options)
    end
  end
end
