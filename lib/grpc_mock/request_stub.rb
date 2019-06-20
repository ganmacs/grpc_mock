# frozen_string_literal: true

require 'grpc_mock/request_pattern'
require 'grpc_mock/response_sequence'
require 'grpc_mock/errors'

module GrpcMock
  class RequestStub
    # @param path [String] gRPC path like /${service_name}/${method_name}
    def initialize(path)
      @request_pattern = RequestPattern.new(path)
      @response_sequence = []
    end

    def with(request = nil, &block)
      @request_pattern.with(request, &block)
      self
    end

    def to_return(*resp)
      @response_sequence << GrpcMock::ResponsesSequence.new(resp)
      self
    end

    def response
      if @response_sequence.empty?
        raise GrpcMock::NoResponseError, 'Must be set some values by using #GrpMock::RequestStub#to_run'
      elsif @response_sequence.size == 1
        @response_sequence.first.next
      else
        if @response_sequence.first.end?
          @response_sequence.shift
        end

        @response_sequence.first.next
      end
    end

    # @param path [String]
    # @param request [Object]
    # @return [Bool]
    def match?(path, request)
      @request_pattern.match?(path, request)
    end
  end
end
