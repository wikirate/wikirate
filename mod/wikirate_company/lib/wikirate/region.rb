module Wikirate
  # "Region" in WikiRate is a generic term that can mean city, county, district, country,
  # continent, or any other geographical area.
  module Region
    class << self
      # FIXME: country needs codename!
      def countries
        @countries ||= region_lookup("Country").values.uniq.sort
      end

      def region_fields field
        Card.search left: { type: :region }, right: field
      end

      def region_lookup field
        @region_lookup ||= {}
        @region_lookup[field] ||= region_fields(field).each_with_object({}) do |fld, hash|
          hash[fld.left_id] = fld.content
        end
      end
    end
  end
end
