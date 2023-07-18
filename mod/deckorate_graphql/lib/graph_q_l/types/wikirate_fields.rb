module GraphQL
  module Types
    module WikirateFields

      def lookup_field fieldname, type, codename = nil, card = nil
        codename ||= fieldname
        plural_fieldname = fieldname.to_s.to_name.vary(:plural).to_sym
        card = codename.card if card.nil?

        plural_field plural_fieldname, codename, type

        define_method plural_fieldname do |limit: 10, offset: 0, **filter|
          card.format.query_class.new(filter, {}, limit: limit, offset: offset).lookup_relation.all
        end
      end

      def card_field fieldname, type, codename = nil
        codename ||= fieldname
        singular_field fieldname, type
        define_method(fieldname) { |**mark| ok_card codename, **mark }
      end

      def cardtype_field fieldname, type, codename = nil
        codename ||= fieldname
        plural_fieldname = fieldname.to_s.to_name.vary(:plural).to_sym
        plural_field plural_fieldname, codename, type

        define_method plural_fieldname do |limit: 10, offset: 0, **filter|
          card_search codename, limit, offset, filter
        end
      end

      def singular_field fieldname, type
        field fieldname, type, null: true do
          argument :name, String, required: false
          argument :id, Integer, required: false
        end
      end

      def plural_field fieldname, codename, type
        field fieldname, [type], null: false do
          argument :limit, Integer, required: false
          argument :offset, Integer, required: false

          codename.card.format.filter_keys.each do |filter|
            if filter == :country
              argument filter, CountryFilterType, required: false
            elsif filter == :value_type
              argument filter, ValueFilterType, required: false
            elsif filter == :research_policy
              argument filter, ResearchPolicyFilterType, required: false
            elsif filter == :metric_type
              argument filter, MetricCategoryFilterType, required: false
            elsif filter == :company_category
              argument filter, CompanyCategoryFilterType, required: false
            elsif filter == :company_group
              argument filter, CompanyGroupFilterType, required: false
            elsif filter == :designer
              argument filter, MetricDesignerFilterType, required: false
            elsif filter == :wikirate_topic
              argument filter, TopicFilterType, required: false
            else
              argument filter, String, required: false
            end
          end
        end
      end

    end
  end
end