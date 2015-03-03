unless ENV['COVERAGE'] == 'false'
  require File.expand_path( '../vendor/wagn/wagn/lib/wagn/simplecov_helper', __FILE__ )
  SimpleCov.start do
    card_simplecov_filters
  end
end
