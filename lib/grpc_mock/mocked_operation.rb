# frozen_string_literal: true

module GrpcMock
  MockedOperation = Struct.new(:call, :metadata, :deadline)
end
