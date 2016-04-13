# alexa-skills-ruby
Simple library to interface with the Alexa Skills Kit

The primary way to interact with this library is by extending the `AlexaSkillsRuby::Handler` class.  Create a subclass and
register event handlers.

The following handlers are available:

* `on_authenticate` - called before checking the ApplicationID
* `on_session_start` - called first if the request is flagged as a new session
* `on_launch` - called for a LaunchRequest
* `on_session_end` - called for a SessionEndedRequest
* `on_intent` called for an IntentRequest.  Takes an optional string argument that specifies which intents it will be trigged on

In event handlers, the following methods are available:

* `request` - returns the current Request object, a `AlexaSkillsRuby::JsonObjects::BaseRequest`
* `session` - returns the current Session object, a `AlexaSkillsRuby::JsonObjects::Session`
* `session_attributes` - Hash containing the current session attributes.  If the response is not flagged to end the session, all values will be sent with the response
* `response` - returns the current Response object, a `AlexaSkillsRuby::JsonObjects::Response`
* `application_id` - returns the value specified in the constructor options
* `logger` - returns the value specified in the constructor options

The `AlexaSkillsRuby::Handler` constructor takes an options hash and processes the following keys:
* `application_id` - If set, will raise a `AlexaSkillsRuby::InvalidApplicationId` if a request's application_id does not match
* `logger` - Will be available through the `logger` method in the handler; not otherwise used by the base class

## Example Sinatra App Using this Library

```ruby
require 'sinatra'
require 'alexa_skills_ruby'

class CustomHandler < AlexaSkillsRuby::Handler

  on_intent("GetZodiacHoroscopeIntent") do
    slots = request.intent.slots
    response.set_output_speech_text("Horiscope Text")
    response.set_simple_card("title", "content")
    logger.info 'GetZodiacHoroscopeIntent processed'
  end

end

post '/' do
  content_type :json

  handler = CustomHandler.new(application_id: ENV['APPLICATION_ID'], logger: logger)

  begin
    handler.handle(request.body.read)
  rescue AlexaSkillsRuby::InvalidApplicationId => e
    logger.error e.to_s
    403
  end

end
```