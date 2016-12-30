module AlexaSkillsRuby
  class SimpleCertificateCache

    def initialize
      @cache = {}
    end

    def get(url)
      @cache[url]
    end

    def set(url, value)
      @cache[url] = value
    end

  end
end