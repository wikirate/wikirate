# FIXME: get card helper from somewhere else
# require_relative "../../../spec/source_helper"

# This class provides an interface to import relationship answers
class RelationshipImportItem < AnswerImportItem
  @columns = { metric: { map: true },
               subject_company: { map: true, type: :wikirate_company },
               object_company: { map: true, type: :wikirate_company },
               year: { map: true },
               value: {},
               source: { map: true, separator: ";" },
               comment: { optional: true } }
end
