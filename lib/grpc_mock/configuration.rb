module GrpcMock
  class Configuration
    attr_accessor :allow_net_connect

    def initialize
      @allow_net_connect = true
    end
  end
end
