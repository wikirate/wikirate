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

    def translate_company_args item
      handle_company_auto_add item, :subject_company, :auto_add_company
      handle_company_auto_add item, :object_company, :auto_add_object_company
      item[:company] = item.delete :subject_company
      item[:related_company] = item.delete :object_company
    end
  end
end
