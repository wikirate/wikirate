format :html do
  view :filter_industry_formgroup, cache: :never do
    select_filter :industry
  end

  def industry_options
    :commons_industry.card.value_options_card.options_hash
  end
end
