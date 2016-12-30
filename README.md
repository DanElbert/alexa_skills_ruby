# alexa-skills-ruby
Simple library to interface with the Alexa Skills Kit

[![Build Status](https://travis-ci.org/DanElbert/alexa_skills_ruby.svg?branch=master)](https://travis-ci.org/DanElbert/alexa_skills_ruby)

The primary way to interact with this library is by extending the `AlexaSkillsRuby::Handler` class.  Create a subclass and
register event handlers.

The following handlers are available:

* `on_verify_signature` - called before checking message certificate and signature
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
* `skip_signature_validation` - If true, skips any message signature or certificate validation
* `certificate_cache` - Optional key that allows use of an external cache for Amazon's certificate.  Must be an instance of an object that has the same method definitions as `AlexaSkillsRuby::SimpleCertificateCache`
* `root_certificates` - If your CA certificates are not accessible to Ruby by default, you may pass a list of either filenames or OpenSSL::X509::Certificate objects for use in validating Amazon's certificate.

The `AlexaSkillsRuby::Handler#handle` method takes 2 arguments: a string containing the body of the request, and a hash of HTTP headers.  If using
signature validation, the headers hash _must_ contain the Signature and SignatureCertChainUrl HTTP headers.

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
    hdrs = { 'Signature' => request.env['HTTP_SIGNATURE'], 'SignatureCertChainUrl' => request.env['HTTP_SIGNATURECERTCHAINURL'] }
    handler.handle(request.body.read, hdrs)
  rescue AlexaSkillsRuby::Error => e
    logger.error e.to_s
    403
  end

end
```