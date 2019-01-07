# frozen_string_literal: true

require 'grpc_mock/api'
require 'grpc_mock/version'
require 'grpc_mock/configuration'
require 'grpc_mock/adapter'
require 'grpc_mock/stub_registry'

module GrpcMock
  extend GrpcMock::Api

  class << self
    def enable!
      adapter.enable!
    end

    def disable!
      adapter.disable!
    end

    def reset!
      GrpcMock.stub_registry.reset!
    end

    def stub_registry
      @stub_registry ||= GrpcMock::StubRegistry.new
    end

    def adapter
      @adapter ||= Adapter.new
    end

    def config
      @config ||= Configuration.new
    end
  end
end
