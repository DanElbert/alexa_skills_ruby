# alexa-skills-ruby
Simple library to interface with the Alexa Skills Kit

## Example Sinatra App Using this Library

```ruby
require 'sinatra'
require 'alexa_skills_ruby'

class CustomHandler < AlexaSkillsRuby::Handler

  on_intent("GetZodiacHoroscopeIntent") do
    slots = request.request.intent.slots
    response.set_output_speech_text("Horiscope Text")
    response.set_simple_card("title", "content")
  end

end

post '/' do

  content_type :json

  handler = CustomHandler.new(application_id: ENV['APPLICATION_ID'])

  begin
    handler.handle(request.body.read)
  rescue AlexaSkillsRuby::InvalidApplicationId => e
    logger.error e.to_s
    403
  end

end
```