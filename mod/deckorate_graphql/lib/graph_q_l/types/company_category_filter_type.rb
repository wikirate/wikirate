module GraphQL
  module Types
    class CompanyCategoryFilterType < BaseEnum
      ::Card.fetch(:commons_company_category).value_options_card.item_names.each do |option|
        value option.url_key, value: option
      end
    end
  end
end
