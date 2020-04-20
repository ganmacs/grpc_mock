# frozen_string_literal: true

module GrpcMock
  class OperationStub
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def execute
      response
    end
  end
end
