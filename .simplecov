unless ENV['COVERAGE'] == 'false'
  SimpleCov.start do
    wagn_simplecov_filters
  end
end
