module AlexaSkillsRuby
  class Handler
    include ActiveSupport::Callbacks
    define_callbacks :verify_signature, :authenticate, :session_start, :launch, :intent, :session_end

    attr_reader :request, :session, :response
    attr_accessor :application_id, :logger, :skip_signature_validation

    def initialize(opts = {})
      if opts[:application_id]
        @application_id = opts[:application_id]
      end

      if opts[:logger]
        @logger = opts[:logger]
      end

      certificate_cache = opts[:certificate_cache] || SimpleCertificateCache.new
      @skip_signature_validation = !!opts[:skip_signature_validation]
      @signature_validator = SignatureValidator.new(certificate_cache)
    end

    def session_attributes
      @session.attributes ||= {}
    end

    def handle(request_json, request_headers = {})
      @skill_request = JsonObjects::SkillsRequest.new(MultiJson.load(request_json))
      @skill_response = JsonObjects::SkillsResponse.new

      @session = @skill_request.session
      @request = @skill_request.request
      @response = @skill_response.response

      run_callbacks :verify_signature do
        unless @skip_signature_validation
          cert_chain_url = request_headers['SignatureCertChainUrl'].to_s.strip
          signature = request_headers['Signature'].to_s.strip
          if cert_chain_url.empty? || signature.empty?
            raise AlexaSkillsRuby::ConfigurationError, 'Missing "SignatureCertChainUrl" or "Signature" header but signature validation is enabled'
          end
          @signature_validator.validate(request_json, cert_chain_url, signature)
        end
      end

      timestamp_diff = (Time.now - Time.iso8601(@request.timestamp)).abs
      raise TimestampValidationError, "Invalid timstamp" if timestamp_diff > 150

      unless @skip_signature_validation
        run_callbacks :verify_signature do
          @signature_validator.validate(request_json, signature_cert_chain_url, signature)
        end
      end

      run_callbacks :authenticate do
        if @application_id
          if @application_id != session.application.application_id
            raise InvalidApplicationId, "Invalid: [#{session.application.application_id}]"
          end
        end
      end

      if session.new
        run_callbacks :session_start
      end

      case request
        when JsonObjects::LaunchRequest
          run_callbacks :launch
        when JsonObjects::IntentRequest
          run_callbacks :intent
        when JsonObjects::SessionEndedRequest
          run_callbacks :session_end
      end

      if response.should_end_session
        @skill_response.session_attributes = {}
      else
        @skill_response.session_attributes = session_attributes
      end

      MultiJson.dump(@skill_response.as_json)
    end

    def self.on_authenticate(&block)
      set_callback :authenticate, :before, block
    end

    def self.on_session_start(&block)
      set_callback :session_start, :before, block
    end

    def self.on_launch(&block)
      set_callback :launch, :before, block
    end

    def self.on_session_end(&block)
      set_callback :session_end, :before, block
    end

    def self.on_intent(intent_name = nil, &block)
      opts = {}
      if intent_name
        opts[:if] = -> { request.intent_name == intent_name }
      end
      set_callback :intent, :before, block, opts
    end

  end
end