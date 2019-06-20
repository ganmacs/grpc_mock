# frozen_string_literal: true

module GrpcMock
  module Response
    class InvalidArgument < StandardError; end

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
                       raise InvalidArgument.new(message: "Invalid exception class: #{exception.class}")
                     end
      end

      def evaluate
        raise @exception.dup
      end
    end

    class Value
      def initialize(value)
        @value = value
      end

      def evaluate
        @value.dup
      end
    end
  end
end
