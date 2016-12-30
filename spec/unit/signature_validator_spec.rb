require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AlexaSkillsRuby::SignatureValidator, x509: true do

  let(:cert_cache) { AlexaSkillsRuby::SimpleCertificateCache.new }
  let(:validator) { AlexaSkillsRuby::SignatureValidator.new(cert_cache).tap { |v| v.add_ca(root_ca) } }
  let(:body) { load_example_json('example_launch.json') }
  let(:signature) { Base64.encode64(get_signature(body)) }

  it 'validates a good signature' do
    validator.validate(body, certificate_url, signature)
  end

  it 'raises on invalid URLs' do
    [
        'http://s3.amazonaws.com/echo.api/echo-api-cert.pem',
        'https://notamazon.com/echo.api/echo-api-cert.pem',
        'https://s3.amazonaws.com/EcHo.aPi/echo-api-cert.pem',
        'https://s3.amazonaws.com/invalid.path/echo-api-cert.pem',
        'https://s3.amazonaws.com:563/echo.api/echo-api-cert.pem'
    ].each do |url|

      stub_request(:get, url).to_return(status: 200, body: signing_cert.to_s)

      expect { validator.validate(body, url, signature) }.to raise_error(AlexaSkillsRuby::SignatureValidationError, /Invalid signature URL:/)
    end
  end

  it 'validates with valid URLs' do
    [
        'https://s3.amazonaws.com/echo.api/echo-api-cert.pem',
        'https://s3.amazonaws.com:443/echo.api/echo-api-cert.pem',
        'https://s3.amazonaws.com/echo.api/../echo.api/echo-api-cert.pem'
    ].each do |url|

      stub_request(:get, url).to_return(status: 200, body: signing_cert.to_s)

      validator.validate(body, url, signature)
    end
  end

  it 'raises on invalid signature' do
    different_body = load_example_json('example_intent.json')
    expect { validator.validate(different_body, certificate_url, signature) }.to raise_error(AlexaSkillsRuby::SignatureValidationError, /Signature is invalid/)
  end

  describe 'with an invalid signing cert' do
    let(:signing_cert) { build_signing_cert(root_ca, signing_key, false) }

    it 'raises an error' do
      expect { validator.validate(body, certificate_url, signature) }.to raise_error(AlexaSkillsRuby::SignatureValidationError, /Invalid for current date/)
    end
  end

end