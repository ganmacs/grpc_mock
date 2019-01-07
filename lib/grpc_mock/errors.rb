module GrpcMock
  class NetConnectNotAllowedError < StandardError
    def initialize(sigunature)
      super("Real GRPC connections are disabled. #{sigunature} is requested")
    end
  end

  class NoResponseError < StandardError
    def initialize(msg)
      super("There is no response error: #{msg}")
    end
  end
end
