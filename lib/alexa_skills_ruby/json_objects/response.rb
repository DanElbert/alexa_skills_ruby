module AlexaSkillsRuby
  module JsonObjects
    class Response < JsonObject
      attributes :should_end_session
      json_object_attribute :output_speech, OutputSpeech
      json_object_attribute :card, Card
      json_object_attribute :reprompt, Reprompt

      def initialize
        self.should_end_session = true
      end

      def set_output_speech_text(text)
        self.output_speech = OutputSpeech.text(text)
        end
      
      def set_output_speech_ssml(ssml)
        self.output_speech = OutputSpeech.ssml(ssml)
      end

      def set_simple_card(title, content)
        self.card = Card.simple(title, content)
      end

      def set_reprompt_speech_text(text)
        os = OutputSpeech.text(text)
        rp = Reprompt.new
        rp.output_speech = os
        self.reprompt = rp
        end
      
      def set_reprompt_speech_ssml(ssml)
        os = OutputSpeech.ssml(ssml)
        rp = Reprompt.new
        rp.output_speech = os
        self.reprompt = rp
      end
    end
  end
end
