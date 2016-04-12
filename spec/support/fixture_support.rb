module FixtureSupport

  def load_json(name)
    File.read(File.expand_path(File.dirname(__FILE__) + '/../fixtures/' + name))
  end

  def load_fixture(name)
    Oj.load(load_json(name))
  end

end