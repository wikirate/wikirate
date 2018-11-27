format :html do
  view :filter_industry_formgroup, cache: :never do
    select_filter :industry
  end

  def industry_options
    card_name = CompanyFilterQuery::INDUSTRY_METRIC_NAME
    Card[card_name].value_options
  end
end

