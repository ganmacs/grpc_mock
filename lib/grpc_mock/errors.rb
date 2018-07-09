module GrpcMock
  class NetConnectNotAllowedError < StandardError
    def initialize(sigunature)
      super("Real GRPC connections are disabled. #{sigunature} is requested")
    end
  end
end
