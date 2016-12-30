require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AlexaSkillsRuby::SignatureValidator do

  let(:validator) { AlexaSkillsRuby::SignatureValidator.new(AlexaSkillsRuby::SimpleCertificateCache.new).tap { |v| v.add_ca(root_ca) } }
  let(:certificate_url) { 'https://s3.amazonaws.com/echo.api/echo-api-cert.pem' }

  before do
    stub_request(:get, certificate_url).to_return(status: 200, body: signing_cert.to_s)
  end

  it 'validates a good signature' do
    body = load_example_json('example_launch.json')
    signature = get_signature(body)
    base64sig = Base64.encode64(signature)

    validator.validate(body, certificate_url, base64sig)
  end

  it 'raises on invalid URLs' do

  end

end