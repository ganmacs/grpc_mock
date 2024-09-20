class HelloInterceptor < ::GRPC::ClientInterceptor

    def request_response(request: nil, call: nil, method: nil, metadata: {}, &block)
      notify(request, method, call, metadata, &block)
    end

    private

    def notify(request, method, _call, metadata)
      code = ::GRPC::Core::StatusCodes::OK
      start_time = Time.now
      response = yield
    rescue StandardError => e
      code = e.is_a?(::GRPC::BadStatus) ? e.code : ::GRPC::Core::StatusCodes::UNKNOWN

      raise
    ensure
      response_time = Time.now
      payload = {
        metadata: metadata,
        rpc_method: method,
        request: request.to_h,
        response: response.to_h,
        response_code: code,
        request_time: start_time,
        response_time: response_time,
        duration: (response_time - start_time)
      }

      payload[:exception] = e.message if e
    end
  end
