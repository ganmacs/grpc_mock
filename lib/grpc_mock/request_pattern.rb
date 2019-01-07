module GrpcMock
  class RequestPattern
    # @param path [String]
    def initialize(path)
      @path = path
      @block = nil
      @request = nil
    end

    def with(request = nil, &block)
      if request.nil? && !block_given?
        raise ArgumentError, '#with method invoked with no arguments. Either options request or block must be specified.'
      end

      @request = request
      @block = block
    end

    def match?(path, request)
      @path == path && (@request.nil? || @request == request) && (@block.nil? || @block.call(path))
    end
  end
end
