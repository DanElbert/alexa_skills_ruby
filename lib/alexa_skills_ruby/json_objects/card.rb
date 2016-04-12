module AlexaSkillsRuby
  module JsonObjects
    class Card < JsonObject
      attributes :type, :title, :content, :text
      json_object_attributes :image, Image

      def self.simple(title, content)
        card = new
        card.type = "Simple"
        card.title = title
        card.content = content
        card
      end
    end
  end
end