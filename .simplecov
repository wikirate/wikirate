unless ENV['COVERAGE'] == 'false'
  require File.expand_path( '../vendor/wagn/lib/wagn/simplecov_helper', __FILE__ )
  SimpleCov.start do
    wagn_simplecov_filters
  end
end
