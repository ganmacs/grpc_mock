# frozen_string_literal: true

module GrpcMock
  class Configuration
    attr_accessor :allow_net_connect, :allow_localhost, :allow

    def initialize
      @allow_net_connect = true
      @allow_localhost = false
      @allow = nil
    end
  end
end
