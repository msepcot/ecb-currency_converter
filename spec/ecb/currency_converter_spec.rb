require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

def rate_comparison(from, to, actual)
  ECB::CurrencyConverter.rate(from, to).should be_within(0.0001).of(actual)
end

def exchange_comparison(amount, from, to, actual)
  ECB::CurrencyConverter.exchange(amount, from, to).should(
    be_within(0.0001).of(actual)
  )
end

describe ECB::CurrencyConverter do
  describe '#exchange' do
    it 'should convert between currencies through the EUR' do
      [ ['AUD', 'LTL', 244.34222], ['BGN', 'LVL',  35.87278],
        ['BRL', 'MXN', 591.82960], ['CAD', 'MYR', 309.46094],
        ['CHF', 'NOK', 624.72594], ['CNY', 'NZD',  20.44337],
        ['CZK', 'PHP', 225.03894], ['DKK', 'PLN',  57.04671],
        ['EUR', 'KRW', 151703.00], ['GBP', 'RON', 525.55477],
        ['HKD', 'RUB', 413.00283], ['HRK', 'SEK', 115.89472],
        ['HUF', 'SGD',   0.57404], ['IDR', 'THB',   0.31147],
        ['ILS', 'TRY',  52.38214], ['INR', 'USD',   1.70152],
        ['JPY', 'ZAR',  10.51728],
      ].each do |from, to, actual|
        exchange_comparison(100, from, to, actual)
      end
    end
  end

  describe '#rate' do
    it 'should match the provided rates when converting from EUR' do
      [ ['AUD', 1.4131],   ['BGN', 1.9558],  ['BRL', 2.9203],
        ['CAD', 1.3635],   ['CHF', 1.2315],  ['CNY', 8.1963],
        ['CZK', 25.680],   ['DKK', 7.4595],  ['GBP', 0.85620],
        ['HKD', 10.3762],  ['HRK', 7.4855],  ['HUF', 293.62],
        ['IDR', 13246.45], ['ILS', 4.8045],  ['INR', 78.6000],
        ['JPY', 127.55],   ['KRW', 1517.03], ['LTL', 3.4528],
        ['LVL', 0.7016],   ['MXN', 17.2832], ['MYR', 4.2195],
        ['NOK', 7.6935],   ['NZD', 1.6756],  ['PHP', 57.790],
        ['PLN', 4.2554],   ['RON', 4.4998],  ['RUB', 42.8540],
        ['SEK', 8.6753],   ['SGD', 1.6855],  ['THB', 41.259],
        ['TRY', 2.5167],   ['USD', 1.3374],  ['ZAR', 13.4148]
      ].each do |currency, value|
        rate_comparison('EUR', currency, value)
      end
    end

    it 'should match the inverted rates when converting to EUR' do
      [ ['AUD', 1.4131],   ['BGN', 1.9558],  ['BRL', 2.9203],
        ['CAD', 1.3635],   ['CHF', 1.2315],  ['CNY', 8.1963],
        ['CZK', 25.680],   ['DKK', 7.4595],  ['GBP', 0.85620],
        ['HKD', 10.3762],  ['HRK', 7.4855],  ['HUF', 293.62],
        ['IDR', 13246.45], ['ILS', 4.8045],  ['INR', 78.6000],
        ['JPY', 127.55],   ['KRW', 1517.03], ['LTL', 3.4528],
        ['LVL', 0.7016],   ['MXN', 17.2832], ['MYR', 4.2195],
        ['NOK', 7.6935],   ['NZD', 1.6756],  ['PHP', 57.790],
        ['PLN', 4.2554],   ['RON', 4.4998],  ['RUB', 42.8540],
        ['SEK', 8.6753],   ['SGD', 1.6855],  ['THB', 41.259],
        ['TRY', 2.5167],   ['USD', 1.3374],  ['ZAR', 13.4148]
      ].each do |currency, value|
        rate_comparison(currency, 'EUR', 1.0 / value)
      end
    end

    it 'should report a rate of 1.0 between the same currency' do
      rate_comparison('KRW', 'KRW', 1.0)
    end

    it 'should convert rates between currencies through the EUR' do
      [ ['AUD', 'LTL', 2.44342], ['BGN', 'LVL', 0.35872],
        ['BRL', 'MXN', 5.91829], ['CAD', 'MYR', 3.09460],
        ['CHF', 'NOK', 6.24725], ['CNY', 'NZD', 0.20443],
        ['CZK', 'PHP', 2.25038], ['DKK', 'PLN', 0.57046],
        ['GBP', 'RON', 5.25554], ['HKD', 'RUB', 4.13002],
        ['HRK', 'SEK', 1.15894], ['HUF', 'SGD', 0.00574],
        ['IDR', 'THB', 0.00311], ['ILS', 'TRY', 0.52382],
        ['INR', 'USD', 0.01701], ['JPY', 'ZAR', 0.10517],
      ].each do |from, to, value|
        rate_comparison(from, to, value)
      end
    end

    describe '#validate' do
      describe ECB::UnknownCurrencyError do
        it 'should raise an error on an unsupported currency code' do
          expect {
            ECB::CurrencyConverter.exchange(100, 'USD', 'UNKNOWN')
          }.to raise_error(ECB::UnknownCurrencyError)

          expect {
            ECB::CurrencyConverter.exchange(100, 'UNKNOWN', 'USD')
          }.to raise_error(ECB::UnknownCurrencyError)
        end

        it 'should not raise an error for supported currency codes' do
          expect {
            ECB::CurrencyConverter.exchange(100, 'EUR', 'USD')
          }.to_not raise_error(ECB::UnknownCurrencyError)
        end
      end

      describe ECB::MissingExchangeRateError do
        before do
          ECB::CurrencyConverter.send(:load_data!)

          euro = ECB::CurrencyConverter.instance_variable_get(:@euro)
          euro['USD'] = nil

          ECB::CurrencyConverter.instance_variable_set(:@euro, euro)
        end

        after do
          ECB::CurrencyConverter.instance_variable_set(:@euro, nil)
        end

        it 'should raise an error if supported data is missing' do
          expect {
            ECB::CurrencyConverter.exchange(100, 'EUR', 'USD')
          }.to raise_error(ECB::MissingExchangeRateError)

          expect {
            ECB::CurrencyConverter.exchange(100, 'USD', 'EUR')
          }.to raise_error(ECB::MissingExchangeRateError)
        end

        it 'should not raise an error if we have data available' do
          expect {
            ECB::CurrencyConverter.exchange(100, 'EUR', 'GBP')
          }.to_not raise_error(ECB::MissingExchangeRateError)

          expect {
            ECB::CurrencyConverter.exchange(100, 'GBP', 'EUR')
          }.to_not raise_error(ECB::MissingExchangeRateError)
        end
      end
    end
  end
end
