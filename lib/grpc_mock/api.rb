# frozen_string_literal: true

require 'grpc_mock/request_stub'
require 'grpc_mock/matchers/request_including_matcher'

module GrpcMock
  module Api
    # @param path [String]
    def stub_request(path)
      GrpcMock.stub_registry.register_request_stub(GrpcMock::RequestStub.new(path))
    end

    # @param values [Hash]
    def request_including(values)
      GrpcMock::Matchers::RequestIncludingMatcher.new(values)
    end

    def disable_net_connect!(allow_localhost: false, allow: nil)
      GrpcMock.config.allow_net_connect = false
      GrpcMock.config.allow_localhost = allow_localhost
      GrpcMock.config.allow = allow
    end

    def allow_net_connect!
      GrpcMock.config.allow_net_connect = true
    end
  end
end
