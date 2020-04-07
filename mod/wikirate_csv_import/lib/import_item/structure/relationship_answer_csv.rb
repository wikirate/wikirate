# FIXME: get card helper from somewhere else
# require_relative "../../../spec/source_helper"

# This class provides an interface to import relationship answers
class ImportItem
  module Structure
    class RelationshipAnswerCsv < AnswerCsv
      @columns = [:designer, :title, :company, :related_company, :year, :value, :source]
      @required = :all

      def initialize row, index, import_manager=nil
        super
        @row[:metric] = metric
      end

      def import_company _company_key=:company
        ImportLog.debug "  importing company:"
        @row[:company] = super(:company)
        ImportLog.debug "  #{@row[:company]}"
        ImportLog.debug "  importing related company:"
        @row[:related_company] = super(:related_company).tap do |ret|
          ImportLog.debug "  #{ret}"
        end
      end

      def metric
        @metric ||= "#{designer}+#{title}"
      end
    end
  end
end
