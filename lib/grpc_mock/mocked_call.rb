# frozen_string_literal: true

require 'grpc'
require 'grpc_mock/mocked_operation'

module GrpcMock
  class MockedCall
    attr_reader :deadline, :metadata

    def initialize(metadata: {}, deadline: nil)
      @metadata = sanitize_metadata(metadata)
      @deadline = deadline
    end

    def multi_req_view
      GRPC::ActiveCall::MultiReqView.new(self)
    end

    def single_req_view
      GRPC::ActiveCall::SingleReqView.new(self)
    end

    def operation
      GrpcMock::MockedOperation.new(self, metadata, deadline)
    end

    private

    def sanitize_metadata(metadata)
      # Largely based on
      # - grpc_rb_md_ary_fill_hash_cb https://github.com/grpc/grpc/blob/v1.29.1/src/ruby/ext/grpc/rb_call.c#L390-L465
      # - grpc_rb_md_ary_convert https://github.com/grpc/grpc/blob/v1.29.1/src/ruby/ext/grpc/rb_call.c#L490-L511
      # - grpc_rb_md_ary_to_h https://github.com/grpc/grpc/blob/v1.29.1/src/ruby/ext/grpc/rb_call.c#L513-L541
      # See also https://github.com/grpc/grpc/blob/v1.29.1/doc/PROTOCOL-HTTP2.md for specification

      raise TypeError, "got <#{metadata.class}>, want <Hash>" unless metadata.is_a?(Hash)

      headers = []
      metadata.each do |key, value|
        raise TypeError, "bad type for key parameter" unless key.is_a?(String) || key.is_a?(Symbol)

        key = key.to_s
        # https://github.com/grpc/grpc/blob/v1.29.1/src/core/lib/surface/validate_metadata.cc#L61-L79
        raise ArgumentError, "'#{key}' is an invalid header key" unless key.match?(/\A[a-z0-9\-_.]+\z/) && key != ''
        raise ArgumentError, "Header values must be of type string or array" unless value.is_a?(String) || value.is_a?(Array)

        Array(value).each do |elem|
          raise TypeError, "Header value must be of type string" unless elem.is_a?(String)

          unless key.end_with?('-bin')
            # Non-binary metadata are translated as plain HTTP2 headers, thus this requirement.
            # https://github.com/grpc/grpc/blob/v1.29.1/src/core/lib/surface/validate_metadata.cc#L85-L92
            raise ArgumentError, "Header value '#{elem}' has invalid characters" unless elem.match(/\A[ -~]+\z/)

            # "ASCII-Value should not have leading or trailing whitespace. If it contains leading or trailing whitespace, it may be stripped."
            # https://github.com/grpc/grpc/blob/v1.29.1/doc/PROTOCOL-HTTP2.md
            elem = elem.strip
          end
          headers << [key, elem]
        end
      end

      metadata = {}
      headers.each do |key, elem|
        if metadata[key].nil?
          metadata[key] = elem
        elsif metadata[key].is_a?(Array)
          metadata[key] << elem
        else
          metadata[key] = [metadata[key], elem]
        end
      end

      metadata
    end
  end
end
