module AlexaSkillsRuby

  class Error < StandardError
  end

  class InvalidApplicationId < Error
  end

  class ConfigurationError < Error
  end

  class SignatureValidationError < Error
  end

  class TimestampValidationError < Error
  end
end
