# ECB::CurrencyConverter

Currency Conversion using the European Central Bank's Euro foreign exchange
reference rates. All calculations are performed and returned in +BigDecimal+.

## Installation

Add this line to your application's Gemfile:

    gem 'ecb-currency_converter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ecb-currency_converter

## Usage

To convert between two currencies:

    ECB::CurrencyConverter.exchange(100, 'EUR', 'USD').to_f
    => 133.74

    ECB::CurrencyConverter.exchange(100, 'USD', 'EUR').to_f
    => 74.77194556602363

To convert between two currencies using historical data:

    date = Date.parse('2013-05-17')

    ECB::CurrencyConverter.exchange(100, 'EUR', 'USD', date).to_f
    => 128.69

    ECB::CurrencyConverter.exchange(100, 'USD', 'EUR', date).to_f
    => 77.70611547128759


To get the most recent exchange rate between two currencies:

    ECB::CurrencyConverter.rate('EUR', 'USD').to_f
    => 1.3374

    ECB::CurrencyConverter.rate('USD', 'EUR').to_f
    => 0.7477194556602362

To get the historical exchange rate between two currencies:

    date = Date.parse('2013-05-17')

    ECB::CurrencyConverter.rate('EUR', 'USD', date).to_f
    => 1.2869

    ECB::CurrencyConverter.rate('USD', 'EUR', date).to_f
    => 0.777061154712876

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
