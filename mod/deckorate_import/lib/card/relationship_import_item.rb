class Card
  # This class provides an interface to import relationship answers
  class RelationshipImportItem < AnswerImportItem
    extend CompanyImportHelper

    @columns = { metric: { map: true, suggest: true },
                 subject_company: { map: true, type: :wikirate_company, suggest: true,
                                    auto_add: true, alias: "Company" },
                 object_company: { map: true, type: :wikirate_company, suggest: true,
                                   auto_add: true, alias: "Related Company" },
                 year: { map: true },
                 value: {},
                 source: { map: true, separator: ";", auto_add: true },
                 comment: { optional: true } }

    # NOTE: lookup table does not contain source / comment
    CSV_KEYS = %i[relationship_id relationship_link metric answer_id
                  metric subject_company metric_company year value].freeze

    def translate_company_args hash
      hash[:company] = hash.delete :subject_company
      hash[:related_company] = hash.delete :object_company
    end

    def csv_line_for_card card
      card.lookup.csv_line
    end

    class << self
      def export_csv_header
        Relationship.csv_titles
      end
    end
  end
end
