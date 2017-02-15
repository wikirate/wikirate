require File.expand_path "../../../spec/source_helper", __FILE__

class RelationshipMetricAnswer
  include Card::Model::SaveHelper
  include SourceHelper

  REQUIRED = [:designer, :title, :company_1, :company_2, :year, :value, :source]

  def initialize row
    @row = row
    REQUIRED.each do |key|
      raise Error, "value for #{key} missing" unless row[key].present?
    end
    @designer = row[:designer]
    @title = row[:title]
  end

  def create
    ensure_metric_answer
    source_card = ensure_source
    add_relationship_answer source_card
    ensure_inverse_answer
  end

  private

  def ensure_metric_answer
    ensure_answer answer_name
  end

  def ensure_anwer answer_name
    answer = Card.fetch answer_name, new: { type: "Metric Value" }
    if answer
      update_metric_answer answer
    else
      create_metric_answer answer
    end
  end

  def create_metric_answer answer
    answer.subcards = { "+value" => "1" }
    answer.save!
  end

  def update_metric_answer answer
    value = answer.fetch trait: :value
    value.update_attributes! content: (value.content.to_i + 1).to_s
  end

  def ensure_source
    create_link_source @row[:source]
  end

  def add_relationship_answer source
    Card.create name: [answer_name, @row[:company_2]].join("+"),
                type: "Relationship Answer",
                content: @row[:value],
                subcards: { "+source" => source.name }
  end

  def ensure_inverse_answer
    ensure_answer inverse_answer_name
  end

  def answer_name
    @answer_name ||=
      [:designer, :title, :company_1, :year].map { |f| @row[f] }.join("+")
  end

  def inverse_answer_name
    @inverse_answer_name ||=
      [:designer, :inverse, :company_2, :year].map { |f| @row[f] }.join("+")
  end
end
