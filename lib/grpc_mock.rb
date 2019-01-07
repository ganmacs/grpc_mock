require 'grpc_mock/api'
require 'grpc_mock/version'
require 'grpc_mock/configuration'
require 'grpc_mock/adapter'

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

    def disable_net_connect!
      config.allow_net_connect = false
    end

    def allow_net_connect!
      config.allow_net_connect = true
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
