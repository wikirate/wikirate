# FIXME: get card helper from somewhere else
# require_relative "../../../spec/source_helper"

# This class provides an interface to import relationship answers
class CSVRow
  module Structure
    class RelationshipAnswerCSV < AnswerCSV
      @columns = [:designer, :title, :company, :related_company, :year, :value, :source]
      @required = :all

      def import_company
        CompanyCSV.new({ company: original_row[:company] },
                       @row_index, @import_manager).import
        CompanyCSV.new({ related_company: original_row[:related_company] },
                       @row_index, @import_manager, :related_company).import
      end
    end
  end
end
