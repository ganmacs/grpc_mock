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

      def evaluate(_request = nil, _call = nil)
        raise @exception.dup
      end
    end

    class Value
      def initialize(value)
        @value = value
      end

      def evaluate(_request = nil, _call = nil)
        @value.dup
      end
    end

    class BlockValue
      def initialize(block)
        @block = block
      end

      def evaluate(request, call = nil)
        if @block.arity == 1
          # NOTE: just for backwards compatibility
          @block.call(request)
        else
          @block.call(request, call)
        end
      end
    end
  end
end
