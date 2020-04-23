# frozen_string_literal: true

require 'grpc'
require 'grpc_mock/errors'
require 'grpc_mock/operation_stub'

module GrpcMock
  class GrpcStubAdapter
    # To make hook point for GRPC::ClientStub
    # https://github.com/grpc/grpc/blob/bec3b5ada2c5e5d782dff0b7b5018df646b65cb0/src/ruby/lib/grpc/generic/service.rb#L150-L186
    module MockStub
      def request_response(method, request, *args, **opts)
        unless GrpcMock::GrpcStubAdapter.enabled?
          return super
        end

        mock = GrpcMock.stub_registry.response_for_request(method, request)
        if mock
          # TODO: support returning operation in error case too
          if opts[:return_op]
            OperationStub.new response: mock.evaluate,
                              metadata: opts[:metadata]
          else
            mock.evaluate
          end
        elsif GrpcMock.config.allow_net_connect
          super
        else
          raise NetConnectNotAllowedError, method
        end
      end

      # TODO
      def client_streamer(method, requests, *args)
        unless GrpcMock::GrpcStubAdapter.enabled?
          return super
        end

        r = requests.to_a       # FIXME: this may not work
        mock = GrpcMock.stub_registry.response_for_request(method, r)
        if mock
          mock.evaluate
        elsif GrpcMock.config.allow_net_connect
          super
        else
          raise NetConnectNotAllowedError, method
        end
      end

      def server_streamer(method, request, *args)
        unless GrpcMock::GrpcStubAdapter.enabled?
          return super
        end

        mock = GrpcMock.stub_registry.response_for_request(method, request)
        if mock
          mock.evaluate
        elsif GrpcMock.config.allow_net_connect
          super
        else
          raise NetConnectNotAllowedError, method
        end
      end

      def bidi_streamer(method, requests, *args)
        unless GrpcMock::GrpcStubAdapter.enabled?
          return super
        end

        r = requests.to_a       # FIXME: this may not work
        mock = GrpcMock.stub_registry.response_for_request(method, r)
        if mock
          mock.evaluate
        elsif GrpcMock.config.allow_net_connect
          super
        else
          raise NetConnectNotAllowedError, method
        end
      end
    end
    GRPC::ClientStub.prepend MockStub

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
