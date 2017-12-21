# lookup table for metric answers

class Answer < ActiveRecord::Base
  include LookupTable
  extend AnswerClassMethods

  include Filter
  include Validations
  include EntryFetch

  validates :answer_id, numericality: { only_integer: true }, presence: true,
            unless: :virtual?
  validate :must_be_an_answer, :card_must_exist, :metric_must_exit

  def card_column
    :answer_id
  end

  def card
    return super if answer_id
    @card ||= virtual_answer_card
  end

  def virtual_answer_card name=nil, val=nil
    name ||= [record_name, year.to_s]
    val ||= value
    Card.new(name: name, type_id: Card::MetricValueID).tap do |card|
      card.define_singleton_method(:value) { val }
      card.define_singleton_method(:value_card) do
        Card.new name: [name, :value], content: val
      end
    end
  end

  def delete
    super.tap do
      if (latest_year = latest_year_in_db)
        Answer.where(record_id: record_id, year: latest_year)
              .update_all(latest: true)
      end
    end
  end

  def latest_year_in_db
    Answer.where(record_id: fetch_record_id).maximum(:year)
  end

  def latest_to_false
    Answer.where(record_id: record_id, latest: true)
          .update_all(latest: false)
  end

  def latest= value
    latest_to_false if @new_latest
    super
  end

  def self.csv_title
    CSV.generate_line ["ANSWER ID", "METRIC NAME", "COMPANY NAME", "YEAR", "VALUE"]
  end

  def csv_line
    CSV.generate_line [answer_id, metric_name, company_name, year, value]
  end

  def update_value value
    update_attributes! value: value,
                      numeric_value: to_numeric_value(value),
                      updated_at: Time.now
                      # FIXME: editor_id column not in test db
                      # editor_id: Card::Auth.current_id
  end

  def calculated_answer metric_card, company, year, value
    ensure_record metric_card, company
    @card = virtual_answer_card metric_card.metric_value_name(company, year), value
    define_singleton_method(:fetch_creator_id) { Card::Auth.current_id }
    refresh
    self
  end

  def self.create_calculated_answer metric_card, company, year, value
    Answer.new.calculated_answer metric_card, company, year, value
  end

  def company_key
    company_name.to_name.key
  end

  def metric_key
    metric_name.to_name.key
  end

  private

  def ensure_record metric_card, company
    return if Card[metric_card, company]
    Card.create! name: [metric_card, company]
  end

  def metric_card
    @metric_card ||= Card.quick_fetch(fetch_metric_name)
  end

  def method_missing method_name, *args, &block
    card.send method_name, *args, &block
  end

  def respond_to_missing? *args
    card.respond_to?(*args) || super
  end

  def is_a? klass
    klass == Card || super
  end

  def to_numeric_value val
    return if unknown?(val) || !val.number?
    val.to_d
  end

  def unknown? val
    val.casecmp("unknown").zero?
  end

  # true if there is no card for this answer
  def virtual?
    card&.new_card?
  end
end

require_relative "answer/active_record_extension"
Answer.const_get("ActiveRecord_Relation").send :include, Answer::ActiveRecordExtension
