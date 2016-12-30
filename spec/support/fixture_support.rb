module FixtureSupport

  def load_json(name)
    File.read(File.expand_path(File.dirname(__FILE__) + '/../fixtures/' + name))
  end

  def load_fixture(name)
    Oj.load(load_json(name))
  end

  def add_timestamp(json)
    json['request']['timestamp'] = Time.now.iso8601
  end

  def load_example_json(name)
    exp = load_fixture(name)
    add_timestamp(exp)
    Oj.dump(exp)
  end

end