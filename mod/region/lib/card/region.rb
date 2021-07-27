class Card
  # "Region" here is a generic term that can mean city, county, district, country,
  # continent, or any other geographical area.
  module Region
    class << self
      # @return [Array] list of country name strings
      def countries
        @countries ||= lookup_val(:country).values.uniq.sort
      end

      # @return [Hash] in the form { region_id1 => field val } for all regions
      #  with field populated
      def lookup_val field
        @lookup_val ||= {}
        @lookup_val[field] ||= cache.fetch("#{field}-vals") do
          build_val_lookup field
        end
      end

      def lookup_region_id field
        @lookup_region_id ||= {}
        @lookup_region_id[field] ||= cache.fetch("#{field}-region-ids") do
          build_region_id_lookup field
        end
      end

      def cache
        Card::Cache[Region]
      end

      # TODO: move to oc mod
      def region_name_for_oc_code oc_code
        oc_code = oc_code.to_s.sub(/^oc_/, "")
        lookup_region_id(OcJurisdictionKeyID)[oc_code]&.cardname
      end

      private

      def build_val_lookup field
        each_field_card field do |region_id, field_val, hash|
          hash[region_id] = field_val
        end
      end

      def build_region_id_lookup field
        each_field_card field do |region_id, field_val, hash|
          hash[field_val] = region_id
        end
      end

      def each_field_card field
        content_method = field == :country ? :first_name : :content
        field_cards(field).each_with_object({}) do |fld, hash|
          yield fld.left_id, fld.send(content_method), hash
        end
      end

      def field_cards field
        Card.search left: { type: :region }, right: field
      end
    end
  end
end
