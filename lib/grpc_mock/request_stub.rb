require 'grpc_mock/resopnse_sequence'
require 'grpc_mock/errors'

module GrpcMock
  class RequestStub
    # @param path [String] gRPC path like /${service_name}/${method_name}
    def initialize(path)
      @path = path
      @response_sequence = []
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

    # only support exact match
    def response_for(path)
      @path == path
    end
  end
end
