require_relative "../../../spec/source_helper"
require_relative "../csv_row"

# This class provides an interface to import relationship answers
class RelationshipAnswerCSVRow < CSVRow
  include SourceHelper

  @columns = [:designer, :title, :company_1, :company_2, :year, :value, :source]
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
    binding.pry if company_1 == "2017" || company_2 == "2017"
    ensure_card company_1, type_id: Card::WikirateCompanyID
    ensure_card company_2, type_id: Card::WikirateCompanyID
  end

  def ensure_source
    create_link_source @row[:source]
  end

  def add_relationship_answer source
    ensure_card [answer_name, company_2],
                type: "Relationship Answer",
                subcards: { "+source" => source.name,
                            "+value" => { content: value, type_id: Card::PhraseID } }
  end

  def answer_name
    @answer_name ||= [designer, title, company_1, year].join("+")
  end
end
