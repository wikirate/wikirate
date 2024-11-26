# lookup table for answers (answers to metric questions)
class Answer < Cardio::Record
  @card_column = :answer_id

  include LookupTable
  extend AnswerClassMethods

  include CardlessAnswers
  include Validations
  include EntryFetch
  include Export
  include Latest
  include AndRelationship

  validates :answer_id, numericality: { only_integer: true }, presence: true,
                        unless: :virtual?
  validate :must_be_a_answer, :card_must_exist, unless: :virtual?
  validate :metric_must_exist

  belongs_to :metric, primary_key: :metric_id

  after_destroy :latest_to_true

  attr_writer :card

  fetcher :metric_id, :company_id, :record_id, :source_count, :source_url,
          :value, :numeric_value, :checkers, :comments, :verification, :unpublished

  define_fetch_method :open_flags, :count_open_flags

  def card
    return @card if @card
    if answer_id
      super
    else
      @card = card_without_answer_id
    end
    @card.answer = self
    @card
  end

  def card_query
    { type: Card::AnswerID, trash: false }
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

  private

  def metric_card
    @metric_card ||= fetch_metric_id&.card
  end

  # companies with +'s in the name were causing invalid metrics...
  def invalid_metric_card?
    !(metric_card&.type_id == Card::MetricID)
  end

  def unknown? val
    self.class.unknown? val
  end
end

require_relative "answer/active_record_extension"
Answer.const_get("ActiveRecord_Relation").send :include, Answer::ActiveRecordExtension
