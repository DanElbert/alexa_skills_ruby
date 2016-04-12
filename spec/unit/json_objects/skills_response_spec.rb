require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe AlexaSkillsRuby::JsonObjects::SkillsResponse do

  let(:response_json) do
    {
      'version' => "1.0",
      'sessionAttributes' => {
        'supportedHoriscopePeriods' => {
          'daily' => true,
          'weekly' => false,
          'monthly' => false
        }
      },
      'response' => {
        'outputSpeech' => {
          'type' => "PlainText",
          'text' => "Today will provide you a new learning opportunity.  Stick with it and the possibilities will be endless. Can I help you with anything else?"
        },
        'card' => {
          'type' => "Simple",
          'title' => "Horoscope",
          'content' => "Today will provide you a new learning opportunity.  Stick with it and the possibilities will be endless."
        },
        'reprompt' => {
          'outputSpeech' => {
            'type' => "PlainText",
            'text' => "Can I help you with anything else?"
          }
        },
        'shouldEndSession' => false
      }
    }
  end

  it 'generates example json' do
    r = AlexaSkillsRuby::JsonObjects::SkillsResponse.new
    r.session_attributes = {'supportedHoriscopePeriods' => {'daily' => true, 'weekly' => false, 'monthly' => false}}
    r.set_output_speech_text("Today will provide you a new learning opportunity.  Stick with it and the possibilities will be endless. Can I help you with anything else?")
    r.set_simple_card('Horoscope', 'Today will provide you a new learning opportunity.  Stick with it and the possibilities will be endless.')
    r.set_reprompt_speech_text('Can I help you with anything else?')
    r.should_end_session = false

    expect(r.as_json).to eq response_json
  end

end