module AlexaSkillsRuby
  module JsonObjects
    class Session < JsonObject
      attributes :new, :session_id, :attributes
      json_object_attribute :application, Application
      json_object_attribute :user, User
    end
  end
end