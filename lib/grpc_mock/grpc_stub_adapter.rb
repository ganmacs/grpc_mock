require 'grpc'
require 'grpc_mock/errors'

module GrpcMock
  class GrpcStubAdapter
    # To make hook point for GRCP::ClientStub
    # https://github.com/grpc/grpc/blob/bec3b5ada2c5e5d782dff0b7b5018df646b65cb0/src/ruby/lib/grpc/generic/service.rb#L150-L186
    ADAPTER_CLASS = Class.new(GRPC::ClientStub) do
      alias_method :original_request_response, :request_response
      alias_method :original_client_streamer, :client_streamer
      alias_method :original_server_streamer, :server_streamer
      alias_method :original_bidi_streamer, :bidi_streamer
    end
    GRPC.send(:remove_const, :ClientStub)
    GRPC.send(:const_set, :ClientStub, ADAPTER_CLASS)

    HOOKED_CLASS = Module.new do
      def request_response(method, req, marshal, unmarshal, **opt)
        if GrpcMock.config.allow_net_connect
          original_request_response(method, req, marshal, unmarshal, **opt)
        else
          raise NetConnectNotAllowedError, method
        end
      end

      def client_streamer(method, requests, marshal, unmarshal, **opt)
        if GrpcMock.config.allow_net_connect
          original_client_streamer(method, requests, marshal, unmarshal, **opt)
        else
          raise NetConnectNotAllowedError, method
        end
      end

      def server_streamer(method, req, marshal, unmarshal, **opt)
        if GrpcMock.config.allow_net_connect
          original_server_streamer(method, req, marshal, unmarshal, **opt)
        else
          raise NetConnectNotAllowedError, method
        end
      end

      def bidi_streamer(method, requests, marshal, unmarshal, **opt)
        if GrpcMock.config.allow_net_connect
          original_bidi_streamer(method, requests, marshal, unmarshal, **opt)
        else
          raise NetConnectNotAllowedError, method
        end
      end
    end

    # This class is only used for disabling grpc_stub_adapter hook
    THROUGHT_CLASS = Module.new do
      def request_response(method, req, marshal, unmarshal, **opt)
        original_request_response(method, req, marshal, unmarshal, **opt)
      end

      def client_streamer(method, requests, marshal, unmarshal, **opt)
        original_client_streamer(method, requests, marshal, unmarshal, **opt)
      end

      def server_streamer(method, req, marshal, unmarshal, **opt)
        original_server_streamer(method, req, marshal, unmarshal, **opt)
      end

      def bidi_streamer(method, requests, marshal, unmarshal, **opt)
        original_bidi_streamer(method, requests, marshal, unmarshal, **opt)
      end
    end

    def enable!
      clean_up
      ADAPTER_CLASS.prepend(HOOKED_CLASS)
    end

    def disable!
      clean_up
      ADAPTER_CLASS.prepend(THROUGHT_CLASS)
    end

    private

    def clean_up
      ADAPTER_CLASS.class_eval do
        undef_method(:request_response)
        undef_method(:client_streamer)
        undef_method(:server_streamer)
        undef_method(:bidi_streamer)
      end
    end
  end
end
