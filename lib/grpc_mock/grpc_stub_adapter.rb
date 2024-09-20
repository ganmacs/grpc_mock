# frozen_string_literal: true

require 'grpc'
require 'grpc_mock/errors'
require 'grpc_mock/mocked_call'

module GrpcMock
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

          interception_context, intercept_args = interceptor_context_and_args(method, request, call, metadata: metadata)

          if return_op
            operation = call.operation
            operation.define_singleton_method(:execute) do
              interception_context.intercept!(:request_response, intercept_args) do
                mock.evaluate(request, call.single_req_view)
              end
            end
            operation
          else
            interception_context.intercept!(:request_response, intercept_args) do
              mock.evaluate(request, call.single_req_view)
            end
          end
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

          interception_context, intercept_args = interceptor_context_and_args(method, requests, call, metadata: metadata)

          if return_op
            operation = call.operation
            operation.define_singleton_method(:execute) do
              interception_context.intercept!(:client_streamer, intercept_args) do
                mock.evaluate(r, call.multi_req_view)
              end
            end
            operation
          else
            interception_context.intercept!(:client_streamer, intercept_args) do
              mock.evaluate(r, call.multi_req_view)
            end
          end
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

          interception_context, intercept_args = interceptor_context_and_args(method, request, call, metadata: metadata)

          if return_op
            operation = call.operation
            operation.define_singleton_method(:execute) do
              interception_context.intercept!(:server_streamer, intercept_args) do
                mock.evaluate(request, call.single_req_view)
              end
            end
            operation
          else
            interception_context.intercept!(:server_streamer, intercept_args) do
              mock.evaluate(request, call.single_req_view)
            end
          end
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

          interception_context, intercept_args = interceptor_context_and_args(method, requests, call, metadata: metadata)

          if return_op
            operation = call.operation
            operation.define_singleton_method(:execute) do
              interception_context.intercept!(:bidi_streamer, intercept_args) do
                mock.evaluate(r, nil) # FIXME: provide BidiCall equivalent
              end
            end
            operation
          else
            interception_context.intercept!(:bidi_streamer, intercept_args) do
              mock.evaluate(r, nil) # FIXME: provide BidiCall equivalent
            end
          end
        elsif GrpcMock.config.allow_net_connect
          super
        else
          raise NetConnectNotAllowedError, method
        end
      end

      def interceptor_context_and_args(method, request_or_requests, call, metadata: {})
        interception_context = @interceptors.build_context
        intercept_args = {
          method: method,
          call: call.interceptable,
          metadata: metadata
        }

        if request_or_requests.is_a?(Enumerable)
          intercept_args[:requests] = request_or_requests
        else
          intercept_args[:request] = request_or_requests
        end

        [interception_context, intercept_args]
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
