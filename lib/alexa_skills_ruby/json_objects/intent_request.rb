module AlexaSkillsRuby
  module JsonObjects
    class IntentRequest < BaseRequest
      json_object_attribute :intent, Intent
    end
  end
end