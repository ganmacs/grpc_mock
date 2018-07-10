require 'grpc'
require 'grpc_mock/errors'

module GrpcMock
  class GrpcStubAdapter
    # To make hook point for GRPC::ClientStub
    # https://github.com/grpc/grpc/blob/bec3b5ada2c5e5d782dff0b7b5018df646b65cb0/src/ruby/lib/grpc/generic/service.rb#L150-L186
    ADAPTER_CLASS = Class.new(GRPC::ClientStub) do
      def request_response(method, *args)
        unless GrpcMock::GrpcStubAdapter.enabled?
          return super
        end

        if GrpcMock.config.allow_net_connect
          super
        else
          raise NetConnectNotAllowedError, method
        end
      end

      def client_streamer(method, *args)
        unless GrpcMock::GrpcStubAdapter.enabled?
          return super
        end

        if GrpcMock.config.allow_net_connect
          super
        else
          raise NetConnectNotAllowedError, method
        end
      end

      def server_streamer(method, *args)
        unless GrpcMock::GrpcStubAdapter.enabled?
          return super
        end

        if GrpcMock.config.allow_net_connect
          super
        else
          raise NetConnectNotAllowedError, method
        end
      end

      def bidi_streamer(method, *args)
        unless GrpcMock::GrpcStubAdapter.enabled?
          return super
        end

        if GrpcMock.config.allow_net_connect
          super
        else
          raise NetConnectNotAllowedError, method
        end
      end
    end
    GRPC.send(:remove_const, :ClientStub)
    GRPC.send(:const_set, :ClientStub, ADAPTER_CLASS)

    def self.disable!
      @enabled = false
    end

    def self.enable!
      @enabled = true
    end

    def self.enabled?
      @enabled
    end

    def enable!
      GrpcMock::GrpcStubAdapter.enable!
    end

    def disable!
      GrpcMock::GrpcStubAdapter.disable!
    end
  end
end
