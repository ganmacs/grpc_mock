# frozen_string_literal: true

require 'grpc_mock/matchers/hash_argument_matcher'

module GrpcMock
  module Matchers
    class RequestIncludingMatcher < HashArgumentMatcher
      def ==(actual)
        if actual.respond_to?(:to_h)
          actual = actual.to_h
        end

        actual = Hash[GrpcMock::Matchers::HashArgumentMatcher.stringify_keys!(actual, deep: true)]
        super { |key, value| inner_including(value, key, actual) }
      rescue NoMethodError
        false
      end

      private

      def inner_including(expect, key, actual)
        if actual.key?(key)
          actual_value = actual[key]
          if expect.is_a?(Hash)
            RequestIncludingMatcher.new(expect) == actual_value
          else
            expect === actual_value
          end
        else
          false
        end
      end

      def inspect
        "request_including(#{@expected.inspect})"
      end
    end
  end
end
