module GrpcMock
  class StubRegistry
    def initialize
      @request_stubs = []
    end

    # @param stub [GrpcMock::RequestStub]
    def register_request_stub(stub)
      @request_stubs << stub
      stub
    end

    def response_for_request(path)
      rstub = @request_stubs.find do |stub|
        stub.response_for(path)
      end

      if rstub
        rstub.response.dup
      end
    end
  end
end
