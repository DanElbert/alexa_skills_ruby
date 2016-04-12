module AlexaSkillsRuby
  module JsonObjects
    class SkillsRequest < JsonObject
      attribute :version
      json_object_attribute :session, Session
      json_object_attribute :request, BaseRequest

      def intent_name
        if self.request.is_a? IntentRequest
          self.request.intent.name
        end
      end
    end
  end
end