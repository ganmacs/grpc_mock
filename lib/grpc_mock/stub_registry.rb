module GrpcMock
  class StubRegistry
    def initialize
      @request_stubs = []
    end

    def reset!
      @request_stubs = []
    end

    # @param stub [GrpcMock::RequestStub]
    def register_request_stub(stub)
      @request_stubs.unshift(stub)
      stub
    end

    # @param path [String]
    # @param request [Object]
    def response_for_request(path, request)
      rstub = @request_stubs.find do |stub|
        stub.match?(path, request)
      end

      if rstub
        rstub.response.dup
      end
    end
  end
end
