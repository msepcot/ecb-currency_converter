require 'ecb/currency_converter/exceptions'
require 'ecb/currency_converter/version'
require 'httparty'

module ECB # :nodoc:
  # = European Central Bank - Currency Converter
  #
  # Convert values or find the most recent foreign exchange reference rate
  # between any of the +CURRENCIES+ supported by the European Central Bank.
  #
  # An overview of the latest Euro foreign exchange reference rates is
  # avaliable at:
  #
  #   http://www.ecb.int/stats/exchange/eurofxref/html/index.en.html
  #
  module CurrencyConverter
    DAILY_URI = 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'
    CURRENCIES = [
      'AUD', # Australian Dollar (A$)
      'BGN', # Bulgarian Lev (BGN)
      'BRL', # Brazilian Real (R$)
      'CAD', # Canadian Dollar (CA$)
      'CHF', # Swiss Franc (CHF)
      'CNY', # Chinese Yuan (CN¥)
      'CZK', # Czech Republic Koruna (CZK)
      'DKK', # Danish Krone (DKK)
      'EUR', # Euro (€)
      'GBP', # British Pound Sterling (£)
      'HKD', # Hong Kong Dollar (HK$)
      'HRK', # Croatian Kuna (HRK)
      'HUF', # Hungarian Forint (HUF)
      'IDR', # Indonesian Rupiah (IDR)
      'ILS', # Israeli New Sheqel (₪)
      'INR', # Indian Rupee (Rs.)
      'JPY', # Japanese Yen (¥)
      'KRW', # South Korean Won (₩)
      'LTL', # Lithuanian Litas (LTL)
      'LVL', # Latvian Lats (LVL)
      'MXN', # Mexican Peso (MX$)
      'MYR', # Malaysian Ringgit (MYR)
      'NOK', # Norwegian Krone (NOK)
      'NZD', # New Zealand Dollar (NZ$)
      'PHP', # Philippine Peso (Php)
      'PLN', # Polish Zloty (PLN)
      'RON', # Romanian Leu (RON)
      'RUB', # Russian Ruble (RUB)
      'SEK', # Swedish Krona (SEK)
      'SGD', # Singapore Dollar (SGD)
      'THB', # Thai Baht (฿)
      'TRY', # Turkish Lira (TRY)
      'USD', # US Dollar ($)
      'ZAR', # South African Rand (ZAR)
    ]

    class << self # Class methods
      # Converts the +value+ between +from+ and +to+ currencies.
      #
      # = Example
      #
      #   ECB::CurrencyConverter.exchange(100, 'EUR', 'USD')
      #   => 133.73999999999998
      #
      #   ECB::CurrencyConverter.exchange(100, 'USD', 'EUR')
      #   => 74.77194556602363
      def exchange(value, from, to)
        value * rate(from, to)
      end

      # Return the exchange rate between +from+ and +to+ currencies.
      #
      # = Example
      #
      #   ECB::CurrencyConverter.rate('EUR', 'USD')
      #   => 1.3374
      #
      #   ECB::CurrencyConverter.rate('USD', 'EUR')
      #   => 0.7477194556602363
      def rate(from, to)
        load_data!
        validate(from, to)

        1.0 / @euro[from] * @euro[to]
      end
    private
      # Load data from European Central Bank's daily XML feed.
      def load_data!
        @euro ||= begin
          response = HTTParty.get(DAILY_URI, format: :xml)

          data = response['Envelope']['Cube']['Cube']['Cube']
          data = data.reduce({}) { |a,e| a[e['currency']] = e['rate'].to_f; a }
          data['EUR'] = 1.0
          data
        end
      end

      # Raise errors for invalid currencies or missing data.
      def validate(from, to)
        raise UnknownCurrencyError.new(from)  unless CURRENCIES.include?(from)
        raise UnknownCurrencyError.new(to)    unless CURRENCIES.include?(to)

        raise MissingExchangeRateError.new(from)  if @euro[from].to_f.zero?
        raise MissingExchangeRateError.new(to)    if @euro[to].to_f.zero?
      end
    end
  end
end
