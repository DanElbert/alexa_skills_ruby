module AlexaSkillsRuby
  module JsonObjects
    class SkillsRequest < JsonObject
      attribute :version
      json_object_attribute :session, Session
      json_object_attribute :request, BaseRequest
    end
  end
end