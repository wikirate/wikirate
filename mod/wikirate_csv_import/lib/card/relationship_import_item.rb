class Card
  # This class provides an interface to import relationship answers
  class RelationshipImportItem < AnswerImportItem
    @columns = { metric: { map: true },
                 subject_company: { map: true, type: :wikirate_company, auto_add: true },
                 object_company: { map: true, type: :wikirate_company, auto_add: true },
                 year: { map: true },
                 value: {},
                 source: { map: true, separator: ";", auto_add: true },
                 comment: { optional: true } }

    # NOTE: lookup table does not contain source / comment
    CSV_KEYS = %i[relationship_id relationship_link metric answer_id
                  metric subject_company metric_company year value].freeze

    def translate_company_args item
      handle_company_auto_add item, :subject_company, :auto_add_company
      handle_company_auto_add item, :object_company, :auto_add_object_company
      item[:company] = item.delete :subject_company
      item[:related_company] = item.delete :object_company
    end

    def csv_line_for_card card
      card.lookup.csv_line
    end

    class << self
      def export_csv_header
        Relationship.csv_title
      end
    end
  end
end
