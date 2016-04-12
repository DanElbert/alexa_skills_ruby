module AlexaSkillsRuby
  module JsonObjects
    class User < JsonObject
      attributes :user_id, :access_token
    end
  end
end