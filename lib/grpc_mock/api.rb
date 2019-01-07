require 'grpc_mock/stub_registry'
require 'grpc_mock/request_stub'

module GrpcMock
  module Api
    def stub_request(path)
      GrpcMock.stub_registry.register_request_stub(GrpcMock::RequestStub.new(path))
    end
  end
end
