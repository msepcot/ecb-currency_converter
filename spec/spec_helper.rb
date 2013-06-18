require 'rubygems'
require 'bundler/setup'

require 'ecb/currency_converter'
require 'fakeweb'

RSpec.configure do |config|
  config.before(:suite) do
    FakeWeb.allow_net_connect = false

    xml = File.read(File.expand_path(
      File.join(File.dirname(__FILE__), 'fixtures', 'eurofxref-daily.xml')
    ))
    FakeWeb.register_uri(:get, ECB::CurrencyConverter::DAILY_URI, body: xml)
  end

  config.after(:suite) do
    FakeWeb.allow_net_connect = true
  end
end
