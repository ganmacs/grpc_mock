require "grpc_mock/version"
require "grpc_mock/configure"
require "grpc_mock/adapter"

module GrpcMock
  class << self
    def enable!
      adapter.enable!
    end

    def disable!
      adapter.disable!
    end

    def disable_net_connect!
      config.allow_net_connect = false
    end

    def allow_net_connect!
      config.allow_net_connect = true
    end

    def adapter
      @adapter ||= Adapter.new
    end

    def config
      @config ||= Configure.new
    end
  end
end
