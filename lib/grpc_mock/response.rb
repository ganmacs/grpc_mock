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

      def call(_request)
        raise @exception.dup
      end
    end

    class Value
      def initialize(value)
        @value = value
      end

      def call(_request)
        @value.dup
      end
    end
  end
end
