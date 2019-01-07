# frozen_string_literal: true

require 'grpc_mock/grpc_stub_adapter'

module GrpcMock
  class Adapter
    def enable!
      adapter.enable!
    end

    def disable!
      adapter.disable!
    end

    private

    def adapter
      @adapter ||= GrpcStubAdapter.new
    end
  end
end
