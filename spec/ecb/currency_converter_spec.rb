require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

def rate_comparison(from, to, date, actual)
  ECB::CurrencyConverter.rate(from, to, date).should(
    be_within(0.0001).of(actual)
  )
end

def exchange_comparison(amount, from, to, date, actual)
  ECB::CurrencyConverter.exchange(amount, from, to, date).should(
    be_within(0.0001).of(actual)
  )
end

describe ECB::CurrencyConverter do
  describe '#exchange' do
    let(:date) { Date.today }

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
        exchange_comparison(100, from, to, date, actual)
      end
    end
  end

  describe '#exchange(historical)' do
    let(:date) { Date.parse('2013-05-17') }

    it 'should convert between currencies through the EUR' do
      [ ['AUD', 'LTL', 261.25907], ['BGN', 'LVL',  35.75518],
        ['BRL', 'MXN', 606.90804], ['CAD', 'MYR', 294.17549],
        ['CHF', 'NOK', 605.61490], ['CNY', 'NZD',  20.13790],
        ['CZK', 'PHP', 203.79391], ['DKK', 'PLN',  55.96049],
        ['EUR', 'KRW', 143784.00], ['GBP', 'RON', 513.40633],
        ['HKD', 'RUB', 404.23576], ['HRK', 'SEK', 113.48831],
        ['HUF', 'SGD',   0.55602], ['IDR', 'THB',   0.30525],
        ['ILS', 'TRY',  50.16654], ['INR', 'USD',   1.82264],
        ['JPY', 'ZAR',   9.15780],
      ].each do |from, to, actual|
        exchange_comparison(100, from, to, date, actual)
      end
    end
  end

  describe '#rate' do
    let(:date) { Date.today }

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
        rate_comparison('EUR', currency, date, value)
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
        rate_comparison(currency, 'EUR', date, 1.0 / value)
      end
    end

    it 'should report a rate of 1.0 between the same currency' do
      rate_comparison('KRW', 'KRW', date, 1.0)
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
        rate_comparison(from, to, date, value)
      end
    end
  end

  describe '#rate(historical)' do
    let(:date) { Date.parse('2013-05-17') }
    it 'should match the provided rates when converting from EUR' do
      [ ['AUD', 1.3216],   ['BGN', 1.9558],  ['BRL', 2.61],
        ['CAD', 1.322],    ['CHF', 1.2449],  ['CNY', 7.904],
        ['CZK', 25.989],   ['DKK', 7.4524],  ['GBP', 0.84475],
        ['HKD', 9.9911],   ['HRK', 7.571],   ['HUF', 290.56],
        ['IDR', 12554.93], ['ILS', 4.7135],  ['INR', 70.606],
        ['JPY', 131.87],   ['KRW', 1437.84], ['LTL', 3.4528],
        ['LVL', 0.6993],   ['MXN', 15.8403], ['MYR', 3.889],
        ['NOK', 7.5393],   ['NZD', 1.5917],  ['PHP', 52.964],
        ['PLN', 4.1704],   ['RON', 4.337],   ['RUB', 40.3876],
        ['SEK', 8.5922],   ['SGD', 1.6156],  ['THB', 38.324],
        ['TRY', 2.3646],   ['USD', 1.2869],  ['ZAR', 12.0764]
      ].each do |currency, value|
        rate_comparison('EUR', currency, date, value)
      end
    end

    it 'should match the inverted rates when converting to EUR' do
      [ ['AUD', 1.3216],   ['BGN', 1.9558],  ['BRL', 2.61],
        ['CAD', 1.322],    ['CHF', 1.2449],  ['CNY', 7.904],
        ['CZK', 25.989],   ['DKK', 7.4524],  ['GBP', 0.84475],
        ['HKD', 9.9911],   ['HRK', 7.571],   ['HUF', 290.56],
        ['IDR', 12554.93], ['ILS', 4.7135],  ['INR', 70.606],
        ['JPY', 131.87],   ['KRW', 1437.84], ['LTL', 3.4528],
        ['LVL', 0.6993],   ['MXN', 15.8403], ['MYR', 3.889],
        ['NOK', 7.5393],   ['NZD', 1.5917],  ['PHP', 52.964],
        ['PLN', 4.1704],   ['RON', 4.337],   ['RUB', 40.3876],
        ['SEK', 8.5922],   ['SGD', 1.6156],  ['THB', 38.324],
        ['TRY', 2.3646],   ['USD', 1.2869],  ['ZAR', 12.0764]
      ].each do |currency, value|
        rate_comparison(currency, 'EUR', date, 1.0 / value)
      end
    end

    it 'should report a rate of 1.0 between the same currency' do
      rate_comparison('KRW', 'KRW', date, 1.0)
    end

    it 'should convert rates between currencies through the EUR' do
      [ ['AUD', 'LTL', 2.61259], ['BGN', 'LVL', 0.35755],
        ['BRL', 'MXN', 6.06908], ['CAD', 'MYR', 2.94175],
        ['CHF', 'NOK', 6.05614], ['CNY', 'NZD', 0.20137],
        ['CZK', 'PHP', 2.03793], ['DKK', 'PLN', 0.55960],
        ['GBP', 'RON', 5.13406], ['HKD', 'RUB', 4.04235],
        ['HRK', 'SEK', 1.13488], ['HUF', 'SGD', 0.00556],
        ['IDR', 'THB', 0.00305], ['ILS', 'TRY', 0.50166],
        ['INR', 'USD', 0.01822], ['JPY', 'ZAR', 0.09157],
      ].each do |from, to, value|
        rate_comparison(from, to, date, value)
      end
    end
  end

  describe '#silence_warnings' do
    let(:date) { Date.parse('2013-05-18') } # NOTE: weekend date
    around { ECB::CurrencyConverter.silence_warnings(false) }

    it 'should warn users when not using their requested date' do
      ECB::CurrencyConverter.silence_warnings
      Kernal.should_not_receive(:warn)

      ECB::CurrencyConverter.exchange(100, 'EUR', 'USD', date)
    end

    it 'should not warn users when they silence warnings' do
      Kernal.should_receive(:warn)

      ECB::CurrencyConverter.exchange(100, 'EUR', 'USD', date)
    end
  end

  describe '#validate' do
    describe ECB::MissingDateError do
      it 'should raise an error for a date more than 90 days ago' do
        expect {
          ECB::CurrencyConverter.exchange(100, 'EUR', 'USD', Date.today - 90)
        }.to raise_error(ECB::MissingDateError)
      end

      it 'should not raise an error for a date less than 90 days ago' do
        expect {
          ECB::CurrencyConverter.exchange(100, 'EUR', 'USD', Date.today - 89)
        }.to_not raise_error(ECB::MissingDateError)
      end
    end

    describe ECB::MissingExchangeRateError do
      before do
        ECB::CurrencyConverter.send(:load_data!, Date.today)

        euro = ECB::CurrencyConverter.instance_variable_get(:@euro)
        euro[Date.today.to_s]['USD'] = nil

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
  end
end
