module AlexaSkillsRuby
  class CertificateValidator

    def initialize(extra_cas = [])
      @store = OpenSSL::X509::Store.new.tap { |store| store.set_default_paths }
      extra_cas.each do |ca|
        case ca
          when String
            @store.add_file(ca)
          when OpenSSL::X509::Certificate
            @store.add_cert(ca)
          else
            raise AlexaSkillsRuby::ConfigurationError, 'root_certificates config option must contain only filenames as strings or OpenSSL::X509::Certificate objects'
        end
      end
    end

    def get_signing_certificate(pem_data)
      chain = chain_certs(get_certs(pem_data))
      chain[0...-1].each do |c|
        if @store.verify(c)
          @store.add_cert(c)
        end
      end

      if @store.verify(chain.last)
        chain.last
      else
        nil
      end
    end

    private

    def get_certs(pem_data)
      pem_data.scan(/-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----\n?/m).map do |pem|
        OpenSSL::X509::Certificate.new(pem)
      end
    end

    def chain_certs(certs)
      certs = certs.dup
      failed = false
      chain = [certs.pop]

      while certs.length > 0 && !failed
        failed = true

        certs.each do |c|
          if c.subject == chain.first.issuer
            failed = false
            chain.unshift(c)
          elsif c.issuer == chain.last.subject
            failed = false
            chain << c
          end
        end
      end

      chain

    end

  end
end