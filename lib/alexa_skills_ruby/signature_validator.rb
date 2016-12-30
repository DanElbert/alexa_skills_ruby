module AlexaSkillsRuby
  class SignatureValidator

    def initialize(certificate_cache)
      @certificate_cache = certificate_cache
    end

    def validate(body, signature_cert_chain_url, signature)

      cert_uri = Addressable::URI.parse(signature_cert_chain_url).normalize
      cert = get_cert_from_cache(cert_uri.to_s)

      unless cert
        raise SignatureValidationError, "Invalid signature URL: [#{cert_uri.to_s}]" unless valid_cert_uri?(cert_uri)
        cert = OpenSSL::X509::Certificate.new(fetch_data(cert_uri.to_s))
        errs = cert_errors(cert)
        raise SignatureValidationError, "Invalid signature: #{errs.join(', ')}" unless errs.empty?
        @certificate_cache.set(cert_uri.to_s, cert.to_s)
      end

      public_key = cert.public_key
      signature = Base64.decode64(signature)
      unless public_key.verify(OpenSSL::Digest::SHA1.new, signature, body)
        raise SignatureValidationError "Signature is invalid"
      end
    end

    def add_ca(cert)
      certificate_store.add_cert(cert)
    end

    private

    def get_cert_from_cache(url)
      cert_data = @certificate_cache.get(url)
      if cert_data
        cert = OpenSSL::X509::Certificate.new(cert_data)
        if valid_cert?(cert)
          cert
        else
          nil
        end
      else
        nil
      end
    end

    def valid_cert_uri?(uri)
      case
        when uri.scheme != 'https'
          false
        when uri.host != 's3.amazonaws.com'
          false
        when ![nil, 443].include?(uri.port)
          false
        when uri.path !~ /^\/echo.api\//
          false
        else
          true
      end
    end

    def valid_cert?(cert)
      cert_errors(cert).empty?
    end

    def cert_errors(cert)
      errors = []
      unless certificate_store.verify(cert)
        errors << 'Unable to verify identity'
      end

      unless (cert.not_before..cert.not_after).include?(Time.now)
        errors << 'Invalid for current date'
      end

      errors
    end

    def certificate_valid?(cert)
      certificate_store.verify(cert)
    end

    def certificate_store
      @store ||= OpenSSL::X509::Store.new.tap do |store|
        store.set_default_paths
      end
    end

    def fetch_data(uri_str, limit = 10)
      raise SignatureValidationError, "too many HTTP redirects while fetching #{uri_str}" if limit == 0

      response = Net::HTTP.get_response(URI(uri_str))

      case response
        when Net::HTTPSuccess then
          response.body
        when Net::HTTPRedirection then
          location = response['location']
          fetch(location, limit - 1)
        else
          response.value
      end
    end

  end
end