module GraphQL
  module Types
    class CountryFilterType < BaseEnum
      ::Card.fetch(:core_country).value_options_card.item_names.each do |option|
        value I18n.transliterate(option.url_key), value: option
      end
    end
  end
end
