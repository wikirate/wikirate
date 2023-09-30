module GraphQL
  module Types
    # Enum FilterType class
    class FilterType < BaseEnum
      class << self
        def card_name_values card_names
          card_names.each do |name|
            name = name.first if name.is_a? Array
            name = name.to_name
            # we exclude option values starting with numerical value
            next if name.start_with?(/\d/)
            value I18n.transliterate(name.url_key), value: name
          end
        end

        def filter_option_values base_codename, filter_name
          options = base_codename.card.format.send("filter_#{filter_name}_options")
          card_name_values options.is_a?(Hash) ? options.values : options
        end
      end
    end
  end
end
