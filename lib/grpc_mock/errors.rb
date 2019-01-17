# frozen_string_literal: true

module GrpcMock
  class NetConnectNotAllowedError < StandardError
    def initialize(sigunature)
      super("Real gRPC connections are disabled. #{sigunature} is requested")
    end
  end

  class NoResponseError < StandardError
    def initialize(msg)
      super("There is no response: #{msg}")
    end
  end
end
