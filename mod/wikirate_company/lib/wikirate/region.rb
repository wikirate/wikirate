module Wikirate
  module Region
    class << self
      # FIXME: country needs codename!
      def countries
        @countries ||= region_lookup("Country").values.uniq.sort
      end

      def regions_for_country country

      end

      def region_fields field
        Card.search left: { type: :region }, right: field
      end

      def region_lookup field
        @region_lookup ||= {}
        @region_lookup[field] ||= region_fields(field).each_with_object({}) do |card, hash|
          hash[card.left_id] = card.content
        end
      end
    end
  end
end
