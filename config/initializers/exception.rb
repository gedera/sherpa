class Exception
  class ServiceError < StandardError
    def to_s
      'SERVICE_ERROR'
    end
  end

  class GatewayError < StandardError
    def to_s
      'GATEWAY_ERROR'
    end
  end

  class UltraCriticError < StandardError
  end

  ServiceClasses = [
    Exception::ServiceError,
    Exception::GatewayError
  ]
end
