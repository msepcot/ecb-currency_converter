# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ecb/currency_converter/version'

Gem::Specification.new do |spec|
  spec.name          = 'ecb-currency_converter'
  spec.version       = ECB::CurrencyConverter::VERSION
  spec.authors       = ['Michael J. Sepcot']
  spec.email         = ['developer@sepcot.com']
  spec.description   = %q{Currency Conversion using the European Central Bank's Euro foreign exchange reference rates.}
  spec.summary       = %q{Currency Conversion using the European Central Bank's Euro foreign exchange reference rates.}
  spec.homepage      = 'https://github.com/msepcot/ecb-currency_converter'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'fakeweb'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'timecop'

  spec.add_dependency 'httparty', '~> 0.11.0'
end
