module GraphQL
  module Types
    # Deckorate Fields for GraphQL contains a number of functions
    # to facilitate the definition of different GraphQL types
    module DeckorateFields
      def lookup_field fieldname, type, codename = nil, is_card = false
        codename ||= fieldname
        plural_fieldname = fieldname.to_s.to_name.vary(:plural).to_sym
        is_card ||= is_card
        plural_lookup_field plural_fieldname, codename, type
        define_method plural_fieldname do |sort_by: :id, sort_dir: :desc, limit: 10, offset: 0, **filter|
          sort = { sort_by => sort_dir }
          lookup_search(codename, is_card, filter,
                        sort: sort, limit: limit, offset: offset)
        end
      end

      def card_field fieldname, type, codename = nil
        codename ||= fieldname
        singular_field fieldname, type
        define_method(fieldname) { |**mark| ok_card codename, **mark }
      end

      def cardtype_field fieldname, type, codename = nil, is_card = false
        codename ||= fieldname
        plural_fieldname = fieldname.to_s.to_name.vary(:plural).to_sym
        plural_cardtype_field plural_fieldname, codename, type
        define_method plural_fieldname do |sort_by: :name, sort_dir: :desc, limit: 10, offset: 0, **filter|
          deckorate_card_search(codename, is_card, filter, sort_by: sort_by,
                                sort_dir: sort_dir, limit: limit, offset: offset)
        end
      end

      def singular_field fieldname, type
        field fieldname, type, null: true do
          argument :name, String, required: false
          argument :id, Integer, required: false
        end
      end

      def plural_cardtype_field fieldname, codename, type
        field fieldname, [type], null: false do
          argument :limit, Integer, required: false
          argument :offset, Integer, required: false
          argument :sort_by, SortByEnum, required: false
          argument :sort_dir, SortDirEnum, required: false

          codename.card.format.filter_keys.each do |filter|
            filter_type = String
            if GraphQL::Types.const_defined?("#{filter.to_s.camelize}FilterType")
              filter_type = GraphQL::Types.const_get("#{filter.to_s.camelize}FilterType")
            end
            argument filter, filter_type, required: false
          end
        end
      end

      def plural_lookup_field fieldname, codename, type
        field fieldname, [type], null: false do
          argument :limit, Integer, required: false
          argument :offset, Integer, required: false

          sort_by_type = GraphQL::Types.const_get("#{codename.to_s.camelize}SortByEnum")
          argument :sort_by, sort_by_type, required: false
          argument :sort_dir, SortDirEnum, required: false

          codename.card.format.filter_keys.each do |filter|
            filter_type = String
            if GraphQL::Types.const_defined?("#{filter.to_s.camelize}FilterType")
              filter_type = GraphQL::Types.const_get("#{filter.to_s.camelize}FilterType")
            end
            argument filter, filter_type, required: false
          end
        end
      end
    end
  end
end
