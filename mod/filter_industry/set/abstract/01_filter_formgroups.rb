format :html do
  view :filter_company_category_formgroup, cache: :never do
    multiselect_filter :company_category
  end

  def company_category_options
    :company_category.card.value_options_card.options_hash
  end
end
