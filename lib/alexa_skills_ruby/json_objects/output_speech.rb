module AlexaSkillsRuby
  module JsonObjects
    class OutputSpeech < JsonObject
      attributes :type, :text, :ssml

      def self.text(text)
        os = new
        os.text = text
        os.type = 'PlainText'
        os
      end

      def self.ssml(ssml)
        os = new
        os.ssml = ssml
        os.type = 'SSML'
        os
      end
    end
  end
end