require 'grpc_mock'

RSpec.configure do |config|
  config.before(:suite) do
    GrpcMock.enable!
  end

  config.after(:suite) do
    GrpcMock.disable!
  end

  config.after(:each) do
    GrpcMock.reset!
  end
end
