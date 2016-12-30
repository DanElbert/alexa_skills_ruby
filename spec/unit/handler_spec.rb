require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AlexaSkillsRuby::Handler do

  class TestHandler < AlexaSkillsRuby::Handler

    attr_reader :auths, :intents, :launch, :ends, :starts

    def initialize(*args)
      super
      @auths = []
      @intents = []
      @launch = []
      @ends = []
      @starts = []
    end

    on_session_start do
      @starts << request
    end

    on_authenticate do
      @auths << request
    end

    on_launch do
      @launch << request
    end

    on_intent do
      @intents << request
    end

    on_intent('special') do
      @intents << request
    end

    on_session_end do
      @ends << request
    end
  end

  let(:handler) { TestHandler.new(skip_signature_validation: true) }

  describe 'with a launch request' do
    let(:request_json) { load_example_json 'example_launch.json' }

    it 'fires the handlers' do
      handler.handle(request_json)

      expect(handler.auths.count).to eq 1
      expect(handler.intents.count).to eq 0
      expect(handler.ends.count).to eq 0
      expect(handler.starts.count).to eq 1
      expect(handler.launch.count).to eq 1
    end
  end

  describe 'with an intent request' do
    let(:request_json) { load_example_json 'example_intent.json' }

    it 'fires the handlers' do
      handler.handle(request_json)

      expect(handler.auths.count).to eq 1
      expect(handler.intents.count).to eq 1
      expect(handler.ends.count).to eq 0
      expect(handler.starts.count).to eq 0
      expect(handler.launch.count).to eq 0
    end
  end

  describe 'with a special intent request' do
    let(:request_json) do
      json = load_fixture 'example_intent.json'
      json['request']['intent']['name'] = 'special'
      add_timestamp(json)
      Oj.dump(json)
    end

    it 'fires the handlers' do
      handler.handle(request_json)

      expect(handler.auths.count).to eq 1
      expect(handler.intents.count).to eq 2
      expect(handler.ends.count).to eq 0
      expect(handler.starts.count).to eq 0
      expect(handler.launch.count).to eq 0
    end
  end

  describe 'with a session ended request' do
    let(:request_json) { load_example_json 'example_session_ended.json' }

    it 'fires the handlers' do
      handler.handle(request_json)

      expect(handler.auths.count).to eq 1
      expect(handler.intents.count).to eq 0
      expect(handler.ends.count).to eq 1
      expect(handler.starts.count).to eq 0
      expect(handler.launch.count).to eq 0
    end
  end

  describe 'with an application_id set' do

    let(:handler) { TestHandler.new({application_id: 'amzn1.echo-sdk-ams.app.000000-d0ed-0000-ad00-000000d00ebe', skip_signature_validation: true}) }

    describe 'with a valid app id in request' do
      let(:request_json) { load_example_json 'example_session_ended.json' }

      it 'fires the handlers' do
        handler.handle(request_json)

        expect(handler.auths.count).to eq 1
        expect(handler.intents.count).to eq 0
        expect(handler.ends.count).to eq 1
        expect(handler.starts.count).to eq 0
        expect(handler.launch.count).to eq 0
      end
    end

    describe 'with an invalid app id in request' do
      let(:request_json) do
        json = load_fixture 'example_intent.json'
        json['session']['application']['applicationId'] = 'broke'
        add_timestamp(json)
        Oj.dump(json)
      end

      it 'fires the handlers' do
        expect { handler.handle(request_json) }.to raise_error AlexaSkillsRuby::InvalidApplicationId

        expect(handler.auths.count).to eq 1
        expect(handler.intents.count).to eq 0
        expect(handler.ends.count).to eq 0
        expect(handler.starts.count).to eq 0
        expect(handler.launch.count).to eq 0
      end
    end
  end

end