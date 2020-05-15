# FIXME: get card helper from somewhere else
# require_relative "../../../spec/source_helper"

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
    item[:company] = item.delete :subject_company
    item[:related_company] = item.delete :object_company
    add_trigger hash, :auto_add_company if @auto_add[:subject_company]
    add_trigger hash, :auto_add_object_company if @auto_add[:object_company]
  end
end
