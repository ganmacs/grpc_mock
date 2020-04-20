# frozen_string_literal: true

module GrpcMock
  class OperationStub
    attr_reader :response, :metadata, :trailing_metadata, :deadline

    def initialize(response:, metadata: nil, deadline: nil)
      @response = response
      @metadata = metadata
      @deadline = deadline

      # TODO: support stubbing
      @trailing_metadata = {}
    end

    def execute
      response
    end

    # TODO: support stubbing
    def cancelled?
      false
    end
  end
end
