module ECB # :nodoc:
  # = ECB Missing Date Error
  #
  # Raised when the data for a date is +nil+.
  #
  # * +date+ - the missing date.
  class MissingDateError < StandardError
    def initialize(date)
      super("Foreign exchange reference rate for #{date.to_s} is missing.")
    end
  end

  # = ECB Missing Exchange Rate Error
  #
  # Raised when the data for a supported currency code is +nil+ or +zero?+.
  #
  # * +currency_code+ - the unsupported ISO 4217 Currency Code.
  class MissingExchangeRateError < StandardError
    def initialize(currency_code)
      super("Foreign exchange reference rate for #{currency_code} is missing.")
    end
  end

  # = ECB Unknown Currency Error
  #
  # Raised when we try to grab data for an unsupported currency code.
  #
  # * +currency_code+ - the unsupported ISO 4217 Currency Code.
  class UnknownCurrencyError < StandardError
    def initialize(currency_code)
      super("#{currency_code} is not supported.")
    end
  end
end
