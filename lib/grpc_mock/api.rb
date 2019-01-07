require 'grpc_mock/request_stub'

module GrpcMock
  module Api
    def stub_request(path)
      GrpcMock.stub_registry.register_request_stub(GrpcMock::RequestStub.new(path))
    end

    def disable_net_connect!
      GrpcMock.config.allow_net_connect = false
    end

    def allow_net_connect!
      GrpcMock.config.allow_net_connect = true
    end
  end
end
