# frozen_string_literal: true

module GrpcMock
  module Response
    class ExceptionValue
      def initialize(exception)
        @exception = case exception
                     when String
                       StandardError.new(exception)
                     when Class
                       exception.new('Exception from GrpcMock')
                     when Exception
                       exception
                     else
                       raise ArgumentError.new(message: "Invalid exception class: #{exception.class}")
                     end
      end

      def evaluate(_request = nil)
        raise @exception.dup
      end
    end

    class Value
      def initialize(value)
        @value = value
      end

      def evaluate(_request = nil)
        @value.dup
      end
    end

    class BlockValue
      def initialize(block)
        @block = block
      end

      def evaluate(request)
        @block.call(request)
      end
    end
  end
end
