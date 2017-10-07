# FIXME: get card helper from somewhere else
# require_relative "../../../spec/source_helper"

# This class provides an interface to import relationship answers
class CSVRow
  module Structure
    class RelationshipAnswer < AnswerCSV
      @columns = [:designer, :title, :company, :related_company, :year, :value, :source]
      @required = :all


      def import_company
        CompanyCSV.new(@row, @row_index, @import_manager).import
        CompanyCSV.new(@row, @row_index, @import_manager, :related_company).import
      end

    end
  end
end
