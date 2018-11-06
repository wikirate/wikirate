# lookup table for metric answers

class Answer < ApplicationRecord
  include LookupTable
  extend AnswerClassMethods

  include CardlessAnswers
  include Filter
  include Validations
  include EntryFetch
  include Csv

  validates :answer_id, numericality: { only_integer: true }, presence: true,
                        unless: :virtual?
  validate :must_be_an_answer, :card_must_exist, unless: :virtual?
  validate :metric_must_exit

  after_destroy :latest_to_true

  def self.existing id
    return unless id
    find_by_answer_id(id) || (refresh(id) && find_by_answer_id(id))
  end

  def card_column
    :answer_id
  end

  def card
    return super if answer_id
    # in the process of creating a hybrid answer we don't want the virtual answer card
    @card ||= find_answer_card || virtual_answer_card
  end

  def latest_year_in_db
    self.record_id ||= fetch_record_id
    Answer.where(record_id: record_id).maximum :year
  end

  def latest_to_false
    Answer.where(record_id: record_id, latest: true).update_all(latest: false)
  end

  def latest_to_true
    return unless (latest_year = latest_year_in_db)
    Answer.where(record_id: record_id, year: latest_year, latest: false)
          .update_all latest: true
  end

  def latest= value
    latest_to_false if @new_latest
    super
  end

  def company_key
    company_name.to_name.key
  end

  def metric_key
    metric_name.to_name.key
  end

  def updater_id
    editor_id || creator_id
  end

  def refresh *fields
    self.record_name = nil if :record_name.in? fields
    # forces regeneration of name of virtual answer card
    super
  end

  def delete_on_refresh?
    super() || (!metric_card&.hybrid? && invalid?)
    # when we override a hybrid metric the answer is invalid because of the
    # missing answer_id, so we check `invalid?` only for non-hybrid metrics)
  end

  private

  def ensure_record metric_card, company
    return if Card[metric_card, company]
    Card.create! name: [metric_card, company], type_id: Card::RecordID
  end

  def metric_card
    @metric_card ||= Card.fetch(fetch_metric_id || fetch_metric_name)
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
    self.class.unknown? val
  end
end

require_relative "answer/active_record_extension"
Answer.const_get("ActiveRecord_Relation").send :include, Answer::ActiveRecordExtension
