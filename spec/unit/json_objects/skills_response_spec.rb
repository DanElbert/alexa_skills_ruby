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
  let(:response_json_ssml) do
    {
        'version'           => "1.0",
        'sessionAttributes' => {
            'supportedHoriscopePeriods' => {
                'daily'   => true,
                'weekly'  => false,
                'monthly' => false
            }
        },
        "response"          => {
            "shouldEndSession" => false,
            "outputSpeech"     => {
                "type" => "SSML",
                "ssml" => "<speak><p>I am in the first paragraph</p><p>I am in the second paragraph</p></speak>"
            },
            "card"             => {
                "type" => "Simple", 
                "title" => "Horoscope", 
                "content" => "Today will provide you a new learning opportunity.  Stick with it and the possibilities will be endless." },
            "reprompt"         => {
                "outputSpeech" => {
                    "type" => "SSML", 
                    "ssml" => "<speak><p>I am reprompting that I am in the first paragraph</p><p>I am reprompting that I am I am in the second paragraph</p></speak>"
                }
            }
        }
    }
  end

  it 'generates example json' do
    sr = AlexaSkillsRuby::JsonObjects::SkillsResponse.new
    r = sr.response
    sr.session_attributes = {'supportedHoriscopePeriods' => {'daily' => true, 'weekly' => false, 'monthly' => false}}
    r.set_output_speech_text("Today will provide you a new learning opportunity.  Stick with it and the possibilities will be endless. Can I help you with anything else?")
    r.set_simple_card('Horoscope', 'Today will provide you a new learning opportunity.  Stick with it and the possibilities will be endless.')
    r.set_reprompt_speech_text('Can I help you with anything else?')
    r.should_end_session = false

    expect(sr.as_json).to eq response_json
  end

  it 'generates example json for ssml' do
    sr                    = AlexaSkillsRuby::JsonObjects::SkillsResponse.new
    r                     = sr.response
    sr.session_attributes = { 'supportedHoriscopePeriods' => { 'daily' => true, 'weekly' => false, 'monthly' => false } }
    r.set_output_speech_ssml("<speak><p>I am in the first paragraph</p><p>I am in the second paragraph</p></speak>")
    r.set_simple_card('Horoscope', 'Today will provide you a new learning opportunity.  Stick with it and the possibilities will be endless.')
    r.set_reprompt_speech_ssml("<speak><p>I am reprompting that I am in the first paragraph</p><p>I am reprompting that I am I am in the second paragraph</p></speak>")
    r.should_end_session = false

    expect(sr.as_json).to eq response_json_ssml
  end

end
