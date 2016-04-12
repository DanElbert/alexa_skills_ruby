module AlexaSkillsRuby
  module JsonObjects
    class SkillsResponse < JsonObject
      attributes :version, :session_attributes
      json_object_attribute :response, Response

      def initialize
        self.version = '1.0'
        self.session_attributes = {}
        self.response = JsonObjects::Response.new
      end

      def set_output_speech_text(text)
        self.response.output_speech = OutputSpeech.text(text)
      end

      def set_simple_card(title, content)
        self.response.card = Card.simple(title, content)
      end

      def set_reprompt_speech_text(text)
        os = OutputSpeech.text(text)
        rp = Reprompt.new
        rp.output_speech = os
        self.response.reprompt = rp
      end

      def should_end_session=(val)
        self.response.should_end_session = val
      end

      def should_end_session
        self.response.should_end_session
      end
    end
  end
end