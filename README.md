# ECB::CurrencyConverter

Currency Conversion using the European Central Bank's Euro foreign exchange reference rates.

## Installation

Add this line to your application's Gemfile:

    gem 'ecb-currency_converter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ecb-currency_converter

## Usage

To convert between two currencies:

    ECB::CurrencyConverter.exchange(100, 'EUR', 'USD')
    => 133.73999999999998

    ECB::CurrencyConverter.exchange(100, 'USD', 'EUR')
    => 74.77194556602363

To get the most recent exchange rate between two currencies:

    ECB::CurrencyConverter.rate('EUR', 'USD')
    => 1.3374

    ECB::CurrencyConverter.rate('USD', 'EUR')
    => 0.7477194556602363

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
