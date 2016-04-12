module AlexaSkillsRuby
  class Handler
    include ActiveSupport::Callbacks
    define_callbacks :authenticate, :session_start, :launch, :intent, :session_end

    attr_reader :request, :response
    attr_accessor :application_id, :logger

    def initialize(opts = {})
      if opts[:application_id]
        @application_id = opts[:application_id]
      end

      if opts[:logger]
        @logger = opts[:logger]
      end
    end

    def handle(request_json)
      @request = JsonObjects::SkillsRequest.new(MultiJson.load(request_json))
      @response = JsonObjects::SkillsResponse.new

      run_callbacks :authenticate do
        if @application_id
          if @application_id != @request.session.application.application_id
            raise InvalidApplicationId, "Invalid: [#{@request.session.application.application_id}]"
          end
        end
      end

      if @request.session.new
        run_callbacks :session_start
      end

      case @request.request
        when JsonObjects::LaunchRequest
          run_callbacks :launch
        when JsonObjects::IntentRequest
          run_callbacks :intent
        when JsonObjects::SessionEndedRequest
          run_callbacks :session_end
      end

      MultiJson.dump(response.as_json)
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
        opts[:if] = -> { @request.intent_name == intent_name }
      end
      set_callback :intent, :before, block, opts
    end

  end
end