module GraphQL
  module Types
    # Company category FilterType to provide all available company categories options
    class CompanyCategoryFilterType < FilterType
      %i[commons company_category].card.value_options_card.item_names.each do |option|
        value option.url_key, value: option
      end
    end
  end
end
