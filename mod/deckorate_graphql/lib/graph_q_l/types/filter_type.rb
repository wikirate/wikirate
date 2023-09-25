module GraphQL
  module Types
    # Enum FilterType class
    class FilterType < BaseEnum
      class << self
        def card_name_values card_names
          card_names.each do |name|
            name = name.to_name
            value I18n.transliterate(name.url_key), value: name
          end
        end

        def filter_option_values base_codename, filter_name
          card_name_values base_codename.card.format.send("filter_#{filter_name}_options")
        end
      end
    end
  end
end
