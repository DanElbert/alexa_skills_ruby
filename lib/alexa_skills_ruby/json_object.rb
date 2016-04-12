module AlexaSkillsRuby
  class JsonObject

    class_attribute :_json_object_properties
    class_attribute :_properties
    self._json_object_properties = {}
    self._properties = []

    def self.json_object_attribute(*args)
      klass = args.pop
      raise "Invalid arguments" unless klass && klass.is_a?(Class) && args.length > 0

      args.compact.map { |a| a.to_sym }.each do |a|
        attr_accessor a
        self._json_object_properties[a.to_sym] = klass
      end
    end

    def self.attribute(*attrs)
      attrs.compact.map { |a| a.to_sym }.each do |a|
        attr_accessor a
        self._properties << a
      end
    end

    class << self
      alias_method :json_object_attributes, :json_object_attribute
      alias_method :attributes, :attribute
    end

    # Copy properties on inheritance.
    def self.inherited(subclass)
      entities = _json_object_properties.dup
      attrs = _properties.dup
      subclass._json_object_properties = entities.each { |k, v| entities[k] = v.dup }
      subclass._properties = attrs
      super
    end

    def initialize(attrs = {})
      populate_from_json(attrs)
    end

    def as_json(options = nil)
      serialize_attributes(_properties + _json_object_properties.keys)
    end

    def to_json(options = nil)
      MultiJson.dump(as_json(options))
    end

    def populate_from_json(attrs)
      return unless attrs

      attrs.each do |k, v|
        meth = "#{get_method_name(k)}=".to_sym
        if self.respond_to? meth
          if json_object_class = _json_object_properties[k.to_sym]
            assign_json_object(meth, v, json_object_class)
          else
            self.send(meth, v)
          end
        end
      end
    end

    def serialize_attributes(attrs)
      json = {}
      attrs.each do |k|
        meth = k.to_sym
        if self.respond_to?(meth)
          if _json_object_properties[k.to_sym]
            val = serialize_json_object(meth)
          else
            val = self.send(meth)
          end
          unless val.nil?
            json[get_attribute_name(k)] = val
          end
        end
      end
      json
    end

    protected

    def assign_json_object(assignment_method, value, klass)

      if value.is_a? Array
        data = value.map { |v| hydrate_entity(v, klass) }
      else
        data = hydrate_entity(value, klass)
      end

      self.send(assignment_method, data)
    end

    def hydrate_entity(json, klass)
      klass.new(json)
    end

    def get_method_name(attr_name)
      attr_name.to_s.gsub(/([a-z])([A-Z])([a-z]|^)/) { |m| "#{m[0]}_#{m[1].downcase}#{m[2]}" }
    end

    def get_attribute_name(meth_name)
      meth_name.to_s.gsub(/([a-z])(_)([a-z])/) { |m| m[0] + m[2].upcase }
    end

    def serialize_json_object(method)
      value = self.send(method)
      case value
        when nil
          nil
        when Array
          value.map { |v| v.as_json }
        else
          value.as_json
      end
    end
  end
end