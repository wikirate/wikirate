format :html do
  def filter_company_category_type
    :multi
  end

  def filter_company_category_options
    :commons_company_category.card.value_options_card.options_hash
  end
end
