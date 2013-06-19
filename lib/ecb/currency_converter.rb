require 'bigdecimal'
require 'bigdecimal/util'
require 'date'
require 'ecb/currency_converter/exceptions'
require 'ecb/currency_converter/version'
require 'httparty'

# = European Central Bank
#
# The reference rates are usually updated by 3 p.m. CET. They are based on a
# regular daily concertation procedure between central banks across Europe and
# worldwide, which normally takes place at 2.15 p.m. CET.
#
# The procedure for computation of Euro Foreign Exchange Reference Rates is
# stated in: http://www.ecb.int/press/pr/date/2010/html/pr101203.en.html
#
# The current procedure for the computation and publication of the foreign
# exchange reference rates will also apply to the currency that is to be added
# to the list:
#
# * The reference rates are based on the daily concertation procedure between
#   central banks within and outside the European System of Central Banks,
#   which normally takes place at 2.15 p.m. CET. The reference exchange rates
#   are published both by electronic market information providers and on the
#   ECB's website shortly after the concertation procedure has been completed.
# * Only one reference exchange rate (i.e. the mid-rate) is published for each
#   currency, using the "certain" method (i.e. EUR 1 = x foreign currency
#   units).
# * The number of significant digits used may vary according to the currency,
#   reflecting market conventions. In most cases, however, five significant
#   digits are used.
# * The euro area national central banks may publish more comprehensive lists
#   of euro reference exchange rates than that published by the ECB.
#
# The ECB pays due attention to ensuring that the published exchange rates
# reflect the market conditions prevailing at the time of the daily
# concertation procedure. Since the exchange rates of the above currencies
# against the euro are averages of buying and selling rates, they do not
# necessarily reflect the rates at which actual market transactions have been
# made. The exchange rates against the euro published by the ECB are released
# for reference purposes only.
module ECB
  # = Currency Converter
  #
  # Convert values or find the most recent foreign exchange reference rate
  # between any of the +CURRENCIES+ supported by the European Central Bank.
  #
  # An overview of the latest Euro foreign exchange reference rates is
  # avaliable at:
  #
  #   http://www.ecb.int/stats/exchange/eurofxref/html/index.en.html
  #
  # All calculations are performed using +BigDecimal+.
  module CurrencyConverter
    BASE_URI  = 'http://www.ecb.europa.eu/stats/eurofxref'
    DAILY_URI = "#{BASE_URI}/eurofxref-daily.xml"
    NINTY_URI = "#{BASE_URI}/eurofxref-hist-90d.xml"

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
      # = Example (Date.today == 2013-06-18)
      #
      #   ECB::CurrencyConverter.exchange(100, 'EUR', 'USD').to_f
      #   => 133.74
      #
      #   ECB::CurrencyConverter.exchange(100, 'USD', 'EUR').to_f
      #   => 74.77194556602363
      #
      # = Historical Example (2013-05-17)
      #
      #   date = Date.parse('2013-05-17')
      #
      #   ECB::CurrencyConverter.exchange(100, 'EUR', 'USD', date).to_f
      #   => 128.69
      #
      #   ECB::CurrencyConverter.exchange(100, 'USD', 'EUR', date).to_f
      #   => 77.70611547128759
      def exchange(value, from, to, date = Date.today)
        value.to_d * rate(from, to, date)
      end

      # Return the exchange rate between +from+ and +to+ currencies.
      #
      # = Example (Date.today == 2013-06-18)
      #
      #   ECB::CurrencyConverter.rate('EUR', 'USD').to_f
      #   => 1.3374
      #
      #   ECB::CurrencyConverter.rate('USD', 'EUR').to_f
      #   => 0.7477194556602362
      #
      # = Historical Example (2013-05-17)
      #
      #   date = Date.parse('2013-05-17')
      #
      #   ECB::CurrencyConverter.rate('EUR', 'USD', date).to_f
      #   => 1.2869
      #
      #   ECB::CurrencyConverter.rate('USD', 'EUR', date).to_f
      #   => 0.777061154712876
      def rate(from, to, date = Date.today)
        load_data!(date)
        date = closest_available_date(date)
        validate(from, to, date)

        BigDecimal('1.0') / data_for(from, date) * data_for(to, date)
      end

      # Silence warning messages that can arise from +closest_available_date+
      def silence_warnings(silence = true)
        @silence_warnings = silence
      end
    private
      # Find the closest date with available data.
      #
      # Returns the requested date if data is available. If not, we search back
      # up to five days to see if there is available data. This is primarily
      # used to handle weekends and holidays when ECB does not publish data. We
      # will print a warning message (see +silence_warnings+) if we are using
      # a date other than the one specified.
      def closest_available_date(date)
        closest = date.to_date
        5.times do
          if @euro.key?(closest.to_s)
            unless closest == date || @silence_warnings
              warn "Foreign exchange reference rate for #{date.to_s} " \
                "is not available, using rate for #{closest.to_s}."
            end
            return closest
          end
          closest = closest - 1
        end
        raise MissingDateError.new(date)
      end

      # Grab the exchange rate for a currency on a particular date.
      def data_for(currency, date)
        @euro[date.to_s][currency] || BigDecimal('0')
      end

      # Load exchange rate data based on the date requested.
      #--
      # NOTE: should we just load the 90-day historical file? It includes the
      #   most recent date, but takes 2-3x the time to load (.6 or .9 seconds,
      #   compared to .3 for the daily feed in local tests).
      # NOTE: this loads the 90-day historical file even if the requested date
      #   is outside the 90-day window.
      #++
      def load_data!(date)
        if date.to_date == Date.today
          @euro ||= load_daily
        elsif !defined?(@euro) || @euro.size < 2
          @euro = load_ninty
        end
      end

      # Load data from European Central Bank's daily XML feed.
      def load_daily
        response = HTTParty.get(DAILY_URI, format: :xml)
        load(response['Envelope']['Cube']['Cube'])
      end

      # Load data from European Central Bank's historical 90-day XML feed.
      def load_ninty
        data = {}

        response = HTTParty.get(NINTY_URI, format: :xml)
        response['Envelope']['Cube']['Cube'].each do |cube|
          data.merge!(load(cube))
        end

        data
      end

      # Load one +Cube+ worth of data.
      def load(hash)
        date = hash['time']
        data = hash['Cube']
        data = data.reduce({}) do |hash, element|
          hash[element['currency']] = BigDecimal.new(element['rate'])
          hash
        end
        data['EUR'] = BigDecimal('1.0')

        { date => data }
      end

      # Raise errors for invalid currencies or missing data.
      def validate(from, to, date)
        raise UnknownCurrencyError.new(from)  unless CURRENCIES.include?(from)
        raise UnknownCurrencyError.new(to)    unless CURRENCIES.include?(to)

        raise MissingExchangeRateError.new(from)  if data_for(from, date).zero?
        raise MissingExchangeRateError.new(to)    if data_for(to, date).zero?
      end
    end
  end
end
