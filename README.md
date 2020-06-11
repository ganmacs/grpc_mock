# GrpcMock [![Build Status](https://travis-ci.org/ganmacs/grpc_mock.svg?branch=master)](https://travis-ci.org/ganmacs/grpc_mock)

Library for stubbing grpc in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grpc_mock'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grpc_mock

## Usage

If you use [RSpec](https://github.com/rspec/rspec), add the following code to spec/spec_helper.rb:

```ruby
require 'grpc_mock/rspec'
```

## Examples

See definition of protocol buffers and gRPC generated code in [spec/exmaples/hello](https://github.com/ganmacs/grpc_mock/tree/master/spec/examples/hello)

### Stubbed request based on path and with the default response

```ruby
GrpcMock.stub_request("/hello.hello/Hello").to_return(Hello::HelloResponse.new(msg: 'test'))

client = Hello::Hello::Stub.new('localhost:8000', :this_channel_is_insecure)
client.hello(Hello::HelloRequest.new(msg: 'hi')) # => Hello::HelloResponse.new(msg: 'test')
```

### Stubbing requests based on path and request

```ruby
GrpcMock.stub_request("/hello.hello/Hello").with(Hello::HelloRequest.new(msg: 'hi')).to_return(Hello::HelloResponse.new(msg: 'test'))

client = Hello::Hello::Stub.new('localhost:8000', :this_channel_is_insecure)
client.hello(Hello::HelloRequest.new(msg: 'hello')) # => send a request to server
client client.hello(Hello::HelloRequest.new(msg: 'hi'))    # => Hello::HelloResponse.new(msg: 'test') (without any requests to server)
```

### Responding dynamically to the stubbed requests

```ruby
GrpcMock.stub_request("/hello.hello/Hello").to_return do |req, call|
  Hello::HelloResponse.new(msg: "#{req.msg} too")
end

client = Hello::Hello::Stub.new('localhost:8000', :this_channel_is_insecure)
client.hello(Hello::HelloRequest.new(msg: 'hi'))    # => Hello::HelloResponse.new(msg: 'hi too')
```

### Real requests to network can be allowed or disabled

```ruby
client = Hello::Hello::Stub.new('localhost:8000', :this_channel_is_insecure)

GrpcMock.disable_net_connect!
client.hello(Hello::HelloRequest.new(msg: 'hello')) # => Raise NetConnectNotAllowedError error

GrpcMock.allow_net_connect!
Hello::Hello::Stub.new('localhost:8000', :this_channel_is_insecure) # => send a request to server
```

### Raising errors

**Exception declared by class**

```ruby
GrpcMock.stub_request("/hello.hello/Hello").to_raise(StandardError)

client = Hello::Hello::Stub.new('localhost:8000', :this_channel_is_insecure)
client.hello(Hello::HelloRequest.new(msg: 'hi')) # => Raise StandardError
```

**or by exception instance**

```ruby
GrpcMock.stub_request("/hello.hello/Hello").to_raise(StandardError.new("Some error"))
```

**or by string**

```ruby
GrpcMock.stub_request("/hello.hello/Hello").to_raise("Some error")
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ganmacs/grpc_mock. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

