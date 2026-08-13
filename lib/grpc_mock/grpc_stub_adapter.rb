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
          if return_op
            operation = call.operation
            operation.define_singleton_method(:execute) do
              mock.evaluate(request, call.single_req_view)
            end
            operation
          else
            mock.evaluate(request, call.single_req_view)
          end
        elsif connection_allowed?
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
          if return_op
            operation = call.operation
            operation.define_singleton_method(:execute) do
              mock.evaluate(r, call.multi_req_view)
            end
            operation
          else
            mock.evaluate(r, call.multi_req_view)
          end
        elsif connection_allowed?
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
          if return_op
            operation = call.operation
            operation.define_singleton_method(:execute) do
              mock.evaluate(request, call.single_req_view)
            end
            operation
          else
            mock.evaluate(request, call.single_req_view)
          end
        elsif connection_allowed?
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
          if return_op
            operation = call.operation
            operation.define_singleton_method(:execute) do
              mock.evaluate(r, nil) # FIXME: provide BidiCall equivalent
            end
            operation
          else
            mock.evaluate(r, nil) # FIXME: provide BidiCall equivalent
          end
        elsif connection_allowed?
          super
        else
          raise NetConnectNotAllowedError, method
        end
      end

      def connection_allowed?
        return true if GrpcMock.config.allow_net_connect

        uri = @host.include?("://") ? URI.parse(@host) : URI.parse("http://#{@host}")
        return true if GrpcMock.config.allow_localhost && localhost_allowed?(uri)

        net_connection_explicitly_allowed?(GrpcMock.config.allow, uri)
      end

      def localhost_allowed?(uri)
        return false unless GrpcMock.config.allow_localhost
        %w(localhost 127.0.0.1 0.0.0.0 [::1]).include?(uri.host)
      end

      def net_connection_explicitly_allowed?(allowed, uri)
        return false unless GrpcMock.config.allow

        case allowed
        when Array
          allowed.any? { |allowed_item| net_connection_explicitly_allowed?(allowed_item, uri) }
        when Regexp
          (uri.to_s =~ allowed) != nil ||
          ("#{uri.scheme}://#{uri.host}" =~ allowed) != nil && uri.port == uri.default_port
        when String
          allowed == uri.to_s ||
          allowed == uri.host ||
          allowed == "#{uri.host}:#{uri.port}" ||
          allowed == "#{uri.scheme}://#{uri.host}:#{uri.port}" ||
          allowed == "#{uri.scheme}://#{uri.host}" && uri.port == uri.default_port
        else
          if allowed.respond_to?(:call)
            allowed.call(uri)
          end
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
