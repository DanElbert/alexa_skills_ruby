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
    end
  end
end
