module ECB # :nodoc:
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
end
