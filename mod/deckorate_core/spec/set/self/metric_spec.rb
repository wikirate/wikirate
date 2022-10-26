RSpec.describe Card::Set::Self::Metric do
  check_views_for_errors views: %i[filter_bars compact_filter_form]
  check_views_for_errors format: :csv, views: :titled
  check_views_for_errors format: :json, views: :molecule
end
