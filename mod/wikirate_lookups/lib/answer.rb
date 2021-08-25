# lookup table for metric answers
class Answer < Cardio::Record
  @card_column = :answer_id
  @card_query = { type_id: Card::MetricAnswerID, trash: false }

  include LookupTable
  include LookupTable::Latest

  extend AnswerClassMethods

  include CardlessAnswers
  include Validations
  include EntryFetch
  include Export

  validates :answer_id, numericality: { only_integer: true }, presence: true,
                        unless: :virtual?
  validate :must_be_an_answer, :card_must_exist, unless: :virtual?
  validate :metric_must_exist

  belongs_to :metric, primary_key: :metric_id

  after_destroy :latest_to_true

  fetcher :metric_id, :company_id, :record_id, :source_count, :source_url, :imported,
          :value, :numeric_value, :checkers, :check_requester, :overridden_value,
          :comments, :verification, :unpublished

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

  def company_key
    company_name.to_name.key
  end

  def metric_key
    metric_name.to_name.key
  end

  def updater_id
    editor_id || creator_id
  end

  def delete_on_refresh?
    super() || invalid_metric_card? || invalid_non_hybrid_answer?
  end

  # other answers in same record
  def latest_context
    self.company_id ||= fetch_company_id
    self.metric_id ||= fetch_metric_id
    Answer.where(company_id: company_id, metric_id: metric_id).where.not(id: id)
  end

  private

  def metric_card
    @metric_card ||= Card.fetch(fetch_metric_id || fetch_metric_name)
  end

  # companies with +'s in the name were causing invalid metrics...
  def invalid_metric_card?
    !(metric_card&.type_id == Card::MetricID)
  end

  def invalid_non_hybrid_answer?
    # when we override a hybrid metric the answer is invalid because of the
    # missing answer_id, so we don't delete invalid hybrids..
    !metric_card.hybrid? && invalid?
  end

  def unknown? val
    self.class.unknown? val
  end
end

require_relative "answer/active_record_extension"
Answer.const_get("ActiveRecord_Relation").send :include, Answer::ActiveRecordExtension
