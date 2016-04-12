require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe AlexaSkillsRuby::JsonObjects::SkillsRequest do

  let(:launch_request_json) do
    load_fixture 'example_launch.json'
  end

  let(:intent_request_json) do
    load_fixture 'example_intent.json'
  end

  let(:session_ended_request_json) do
    load_fixture 'example_session_ended.json'
  end

  it 'constructs a launch request' do
    r = AlexaSkillsRuby::JsonObjects::SkillsRequest.new(launch_request_json)
    expect(r).not_to be_nil
    expect(r.version).to eq '1.0'
    expect(r.session).to be_a AlexaSkillsRuby::JsonObjects::Session
    expect(r.session.new).to eq true
    expect(r.session.session_id).to eq 'amzn1.echo-api.session.0000000-0000-0000-0000-00000000000'
    expect(r.session.application).to be_a AlexaSkillsRuby::JsonObjects::Application
    expect(r.session.application.application_id).to eq 'amzn1.echo-sdk-ams.app.000000-d0ed-0000-ad00-000000d00ebe'
    expect(r.session.attributes).to eq({})
    expect(r.session.user).to be_a AlexaSkillsRuby::JsonObjects::User
    expect(r.session.user.user_id).to eq 'amzn1.account.AM3B00000000000000000000000'
    expect(r.request).to be_a AlexaSkillsRuby::JsonObjects::LaunchRequest
    expect(r.request.type).to eq 'LaunchRequest'
    expect(r.request.request_id).to eq 'amzn1.echo-api.request.0000000-0000-0000-0000-00000000000'
    expect(r.request.timestamp).to eq '2015-05-13T12:34:56Z'
  end

  it 'constructs an intent request' do
    r = AlexaSkillsRuby::JsonObjects::SkillsRequest.new(intent_request_json)
    expect(r.request).to be_a AlexaSkillsRuby::JsonObjects::IntentRequest
    expect(r.request.type).to eq 'IntentRequest'
    expect(r.request.request_id).to eq 'amzn1.echo-api.request.0000000-0000-0000-0000-00000000000'
    expect(r.request.timestamp).to eq '2015-05-13T12:34:56Z'
    expect(r.request.intent).to be_a AlexaSkillsRuby::JsonObjects::Intent
    expect(r.request.intent.name).to eq 'GetZodiacHoroscopeIntent'
    expect(r.request.intent.slots).to be_a Hash
    expect(r.request.intent.slots['ZodiacSign']).to eq('virgo')
  end

  it 'constructs a session ended request' do
    r = AlexaSkillsRuby::JsonObjects::SkillsRequest.new(session_ended_request_json)
    expect(r.request).to be_a AlexaSkillsRuby::JsonObjects::SessionEndedRequest
    expect(r.request.type).to eq 'SessionEndedRequest'
    expect(r.request.request_id).to eq 'amzn1.echo-api.request.0000000-0000-0000-0000-00000000000'
    expect(r.request.timestamp).to eq '2015-05-13T12:34:56Z'
    expect(r.request.reason).to eq 'USER_INITIATED'
  end

end