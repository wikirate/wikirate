# FIXME: get card helper from somewhere else
# require_relative "../../../spec/source_helper"

# This class provides an interface to import relationship answers
class CSVRow
  module Structure
    class RelationshipAnswerCSV < AnswerCSV
      @columns = [:designer, :title, :company, :related_company, :year, :value, :source]
      @required = :all

      def import_company _company_key=:company
        @row[:company] = super(:company)
        @row[:related_company] = super(:related_company)
      end
    end
  end
end
