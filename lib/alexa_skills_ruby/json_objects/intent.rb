module AlexaSkillsRuby
  module JsonObjects
    class Intent < JsonObject
      attributes :name, :slots

      def slots=(val)
        @slots = Hash[(val || {}).map { |k, v| [k, v['value']] }]
      end
    end
  end
end