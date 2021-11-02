# frozen_string_literal: true

require 'grpc'
require 'grpc_mock/errors'
require 'grpc_mock/mocked_call'

module GrpcMock
  MockedOperation = Struct.new(:call, :metadata, :execute)

  class GrpcStubAdapter
    # To make hook point for GRPC::ClientStub
    # https://github.com/grpc/grpc/blob/bec3b5ada2c5e5d782dff0b7b5018df646b65cb0/src/ruby/lib/grpc/generic/service.rb#L150-L186
    module Adapter
      def request_response(method, request, *args, metadata: {}, return_op: false, **kwargs)
        unless GrpcMock::GrpcStubAdapter.enabled?
          return super
        end

        mock = GrpcMock.stub_registry.response_for_request(method, request)
        if mock
          call = GrpcMock::MockedCall.new(metadata: metadata)
          response = mock.evaluate(request, call.single_req_view)
          return GRPC::MockedOperation.new(call, metadata, response) if return_op
          response
        elsif GrpcMock.config.allow_net_connect
          super
        else
          raise NetConnectNotAllowedError, method
        end
      end

      # TODO
      def client_streamer(method, requests, *args, metadata: {}, return_op: false, **kwargs)
        unless GrpcMock::GrpcStubAdapter.enabled?
          return super
        end

        r = requests.to_a       # FIXME: this may not work
        mock = GrpcMock.stub_registry.response_for_request(method, r)
        if mock
          call = GrpcMock::MockedCall.new(metadata: metadata)
          response = mock.evaluate(r, call.multi_req_view)
          return GrpcMock::MockedOperation.new(call, metadata, response) if return_op
          response
        elsif GrpcMock.config.allow_net_connect
          super
        else
          raise NetConnectNotAllowedError, method
        end
      end

      def server_streamer(method, request, *args, metadata: {}, return_op: false, **kwargs)
        unless GrpcMock::GrpcStubAdapter.enabled?
          return super
        end

        mock = GrpcMock.stub_registry.response_for_request(method, request)
        if mock
          call = GrpcMock::MockedCall.new(metadata: metadata)
          response = mock.evaluate(request, call.single_req_view)
          return GrpcMock::MockedOperation.new(call, metadata, response) if return_op
          response
        elsif GrpcMock.config.allow_net_connect
          super
        else
          raise NetConnectNotAllowedError, method
        end
      end

      def bidi_streamer(method, requests, *args, metadata: {}, return_op: false, **kwargs)
        unless GrpcMock::GrpcStubAdapter.enabled?
          return super
        end

        r = requests.to_a       # FIXME: this may not work
        mock = GrpcMock.stub_registry.response_for_request(method, r)
        if mock
          response = mock.evaluate(r, nil) # FIXME: provide BidiCall equivalent
          return GrpcMock::MockedOperation.new(call, metadata, response) if return_op
          response
        elsif GrpcMock.config.allow_net_connect
          super
        else
          raise NetConnectNotAllowedError, method
        end
      end
    end

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

module GRPC
  class ClientStub
    prepend GrpcMock::GrpcStubAdapter::Adapter
  end
end
