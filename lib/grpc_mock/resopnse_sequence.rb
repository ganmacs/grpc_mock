# frozen_string_literal: true

module GrpcMock
  class ResponsesSequence
    attr_accessor :repeat

    def initialize(responses)
      @repeat = 1
      @responses = responses
      @current = 0
      @last = @responses.length - 1
    end

    def end?
      @repeat == 0
    end

    def next
      if @repeat > 0
        response = @responses[@current]
        next_pos
        response
      else
        @responses.last
      end
    end

    private

    def next_pos
      if @last == @current
        @current = 0
        @repeat -= 1
      else
        @current += 1
      end
    end
  end
end
