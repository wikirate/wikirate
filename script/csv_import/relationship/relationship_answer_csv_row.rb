require_relative "../../../spec/source_helper"
require_relative "../csv_row"

# This class provides an interface to import relationship answers
class RelationshipAnswerCSVRow < CSVRow
  include SourceHelper

  @columns = [:designer, :title, :company_1, :company_2, :year, :value, :source]
  @required = :all

  def initialize row, index
    super
    @designer = @row[:designer]
    @title = @row[:title]
  end

  def import
    ensure_companies
    source_card = ensure_source
    ensure_metric_answer
    add_relationship_answer source_card
    ensure_inverse_answer
  end

  private

  def ensure_metric_answer
    ensure_answer answer_name
  end

  def ensure_companies
    ensure_card @row[:company_1], type_id: Card::WikirateCompanyID
    ensure_card @row[:company_2], type_id: Card::WikirateCompanyID
  end

  def ensure_answer answer_name
    if Card.exists? answer_name
      update_metric_answer answer_name
    else
      create_metric_answer answer_name
    end
  end

  def create_metric_answer answer
    create_card answer, type_id: Card::MetricValueID, "+value" => "1"
  end

  def update_metric_answer answer
    value = Card.fetch answer, :value, new: {}
    value.update_attributes! content: (value.content.to_i + 1).to_s
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

  def ensure_inverse_answer
    ensure_answer inverse_answer_name
  end

  def answer_name
    @answer_name ||=
      [:designer, :title, :company_1, :year].map { |f| @row[f] }.join("+")
  end

  def inverse_answer_name
    @inverse_answer_name ||= begin
      inverse_name = Card.fetch(@designer, @title).inverse
      [inverse_name, @row[:company_2], @row[:year]].join("+")
    end
  end
end
