require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AlexaSkillsRuby::JsonObject do

  class TestJsonObject < AlexaSkillsRuby::JsonObject
    attributes :name, :id
    json_object_attribute :attr1, AlexaSkillsRuby::JsonObjects::User
  end

  class ChildTestJsonObject < TestJsonObject
    attribute :another_field
    json_object_attribute :attr2, AlexaSkillsRuby::JsonObjects::User
  end

  class OtherTestJsonObject < AlexaSkillsRuby::JsonObject
    json_object_attribute :attr3, AlexaSkillsRuby::JsonObjects::User
  end

  describe '.json_object_attribute' do

    it 'should keep separate lists for each type' do
      expect(TestJsonObject._json_object_properties.keys).to contain_exactly :attr1
      expect(ChildTestJsonObject._json_object_properties.keys).to contain_exactly :attr1, :attr2
      expect(OtherTestJsonObject._json_object_properties.keys).to contain_exactly :attr3

      expect(TestJsonObject._properties).to contain_exactly :name, :id
      expect(ChildTestJsonObject._properties).to contain_exactly :name, :id, :another_field
      expect(OtherTestJsonObject._properties.length).to eq 0
    end

  end

  describe 'serialization' do

    it 'serializes entities' do
      json_object = TestJsonObject.new
      json_object.attr1 = AlexaSkillsRuby::JsonObjects::User.new
      json_object.attr1.user_id = 5
      json_object.attr1.access_token = 'token'
      json_object.name = 'name'
      json_object.id = 1

      json = json_object.as_json
      expect(json).to eq({ 'attr1' => { 'userId' => 5, 'accessToken' => 'token'}, 'name' => 'name', 'id' => 1 })
    end

  end

  describe 'deserialization' do
    it 'populates the objects' do
      json = { attr1: { id: 5, access_token: 'token'}, name: 'name', id: 1 }
      json_object = TestJsonObject.new(json)
      expect(json_object.name).to eq 'name'
      expect(json_object.attr1).to be_a AlexaSkillsRuby::JsonObjects::User
      expect(json_object.attr1.access_token).to eq 'token'
    end
  end

end