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
    end
  end
end