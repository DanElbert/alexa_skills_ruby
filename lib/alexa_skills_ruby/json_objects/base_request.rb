module AlexaSkillsRuby
  module JsonObjects
    class BaseRequest < JsonObject
      attributes :type, :request_id, :timestamp

      def self.new(*args, &block)
        json = args.first
        subclass = case
                     when self != BaseRequest
                       nil
                     when json.nil?
                        nil
                      when json['type'] == 'LaunchRequest'
                        LaunchRequest
                      when json['type'] == 'IntentRequest'
                        IntentRequest
                      when json['type'] == 'SessionEndedRequest'
                        SessionEndedRequest
                      else
                        nil
                   end

        if subclass
          subclass.new(*args, &block)
        else
          super
        end
      end

    end
  end
end