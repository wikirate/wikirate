unless ENV['COVERAGE'] == 'false'
  require '/opt/wagn/lib/wagn/simplecov_helper'
  SimpleCov.start do
    wagn_simplecov_filters
  end
end
