RSpec.shared_context('x509', { x509: true }) do

  let(:root_key) { OpenSSL::PKey::RSA.new 512 }
  let(:root_ca) { build_root_ca(root_key) }
  let(:signing_key) { OpenSSL::PKey::RSA.new 512 }
  let(:signing_cert) { build_signing_cert(root_ca, signing_key) }

  let(:certificate_url) { 'https://s3.amazonaws.com/echo.api/echo-api-cert.pem' }

  before do
    stub_request(:get, certificate_url).to_return { |_| { status: 200, body: signing_cert.to_s } }
  end

  def build_headers(body)
    {
        'SignatureCertChainUrl' => certificate_url,
        'Signature' => Base64.encode64(get_signature(body))
    }
  end

  def get_signature(body)
    signing_key.sign(OpenSSL::Digest::SHA1.new, body)
  end

  def get_serial
    @serial_counter ||= 0
    @serial_counter += 1
  end

  def build_root_ca(key)
    root_ca = OpenSSL::X509::Certificate.new
    root_ca.version = 2 # cf. RFC 5280 - to make it a "v3" certificate
    root_ca.serial = get_serial
    root_ca.subject = OpenSSL::X509::Name.parse "/DC=org/DC=umn/CN=mpc-root"
    root_ca.issuer = root_ca.subject # root CA's are "self-signed"
    root_ca.public_key = key.public_key
    root_ca.not_before = Time.now
    root_ca.not_after = root_ca.not_before + 2 * 365 * 24 * 60 * 60 # 2 years validity
    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = root_ca
    ef.issuer_certificate = root_ca
    root_ca.add_extension(ef.create_extension("basicConstraints","CA:TRUE",true))
    root_ca.add_extension(ef.create_extension("keyUsage","keyCertSign, cRLSign", true))
    root_ca.add_extension(ef.create_extension("subjectKeyIdentifier","hash",false))
    root_ca.add_extension(ef.create_extension("authorityKeyIdentifier","keyid:always",false))
    root_ca.sign(key, OpenSSL::Digest::SHA256.new)

    root_ca
  end

  def build_signing_cert(root_ca, signing_key, valid = true)
    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = get_serial
    cert.subject = OpenSSL::X509::Name.parse "/DC=org/DC=umn/CN=mpc-root-#{get_serial}"
    cert.issuer = root_ca.subject # root CA is the issuer
    cert.public_key = signing_key.public_key
    if valid
      cert.not_before = Time.now
    else
      cert.not_before = Time.now + 500
    end
    cert.not_after = cert.not_before + 1 * 365 * 24 * 60 * 60 # 1 years validity
    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = cert
    ef.issuer_certificate = root_ca
    cert.add_extension(ef.create_extension("keyUsage","digitalSignature", true))
    cert.add_extension(ef.create_extension("subjectKeyIdentifier","hash",false))
    cert.add_extension(ef.create_extension("subjectAltName","DNS:echo-api.amazon.com",false))
    cert.sign(root_key, OpenSSL::Digest::SHA256.new)

    cert
  end

end