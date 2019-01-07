module GrpcMock
  module Matchers
    # Base class for Hash matchers
    # https://github.com/rspec/rspec-mocks/blob/master/lib/rspec/mocks/argument_matchers.rb
    class HashArgumentMatcher
      def self.stringify_keys!(arg, options = {})
        case arg
        when Array
          arg.map { |elem|
            options[:deep] ? stringify_keys!(elem, options) : elem
          }
        when Hash
          Hash[
            *arg.map { |key, value|
              k = key.is_a?(Symbol) ? key.to_s : key
              v = (options[:deep] ? stringify_keys!(value, options) : value)
              [k,v]
            }.inject([]) {|r,x| r + x}]
        else
          arg
        end
      end

      def initialize(expected)
        @expected = Hash[
          GrpcMock::Matchers::HashArgumentMatcher.stringify_keys!(expected, deep: true).sort,
        ]
      end

      def ==(_actual, &block)
        @expected.all?(&block)
      rescue NoMethodError
        false
      end

      def self.from_rspec_matcher(matcher)
        new(matcher.instance_variable_get(:@expected))
      end
    end
  end
end
