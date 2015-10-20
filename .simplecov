unless ENV['COVERAGE'] == 'false'
  require File.expand_path( '../vendor/wagn/card/lib/card/simplecov_helper', __FILE__ )
  SimpleCov.start do
	  SimpleCov.merge_timeout 3600
	  card_simplecov_filters
  end
end
