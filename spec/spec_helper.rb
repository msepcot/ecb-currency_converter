require 'rubygems'
require 'bundler/setup'

require 'ecb/currency_converter'
require 'fakeweb'
require 'timecop'

RSpec.configure do |config|
  config.before(:suite) do
    Timecop.freeze(Date.parse('2013-06-18'))

    FakeWeb.allow_net_connect = false

    daily = File.read(File.expand_path(
      File.join(File.dirname(__FILE__), 'fixtures', 'eurofxref-daily.xml')
    ))
    FakeWeb.register_uri(:get, ECB::CurrencyConverter::DAILY_URI, body: daily)

    ninty = File.read(File.expand_path(
      File.join(File.dirname(__FILE__), 'fixtures', 'eurofxref-hist-90d.xml')
    ))
    FakeWeb.register_uri(:get, ECB::CurrencyConverter::NINTY_URI, body: ninty)
  end

  config.after(:suite) do
    FakeWeb.allow_net_connect = true
    Timecop.return
  end
end
