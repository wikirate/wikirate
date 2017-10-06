# FIXME: get card helper from somewhere else
# require_relative "../../../spec/source_helper"

# This class provides an interface to import relationship answers
class CSVRow
  module Structure
    class RelationshipAnswer < CSVRow
      require_dependency "csv_row"

      include SourceHelper

      @columns = [:designer, :title, :company, :related_company, :year, :value, :source]
      @required = :all

      def initialize row, index
        super
      end

      def import
        ensure_companies
        source_card = ensure_source
        add_relationship_answer source_card
      end

      private

      def ensure_companies
        ensure_card company, type_id: Card::WikirateCompanyID
        ensure_card related_company, type_id: Card::WikirateCompanyID
      end

      def ensure_source
        create_link_source @row[:source]
      end

      def add_relationship_answer source
        ensure_card [answer_name, related_company],
                    type: "Relationship Answer",
                    subcards: { "+source" => source.name,
                                "+value" => { content: value, type_id: Card::PhraseID } }
      end

      def answer_name
        @answer_name ||= [designer, title, company, year].join("+")
      end
    end
  end
end


# @return updated or created metric value card object
def parse_import_row import_data, source_map
  process_source args, source_map
  return unless valid_value_data? args
  return unless ensure_company_exists args[:company], args
  return unless ensure_company_exists args[:related_company], args
  return unless (create_args = construct_value_args args)
  check_duplication_in_subcards create_args[:name], args[:row]
  return if check_duplication_with_existing create_args[:name], args[:source]
  add_subcard create_args.delete(:name), create_args
end
