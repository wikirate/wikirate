# lookup table for records (records to metric questions)
class Record < Cardio::Record
  @card_column = :record_id

  include LookupTable
  extend RecordClassMethods

  include CardlessRecords
  include Validations
  include EntryFetch
  include Export
  include Latest
  include AndRelationship

  validates :record_id, numericality: { only_integer: true }, presence: true,
                        unless: :virtual?
  validate :must_be_a_record, :card_must_exist, unless: :virtual?
  validate :metric_must_exist

  belongs_to :metric, primary_key: :metric_id

  after_destroy :latest_to_true

  attr_writer :card

  fetcher :metric_id, :company_id, :record_log_id, :source_count, :source_url,
          :value, :numeric_value, :checkers, :comments, :verification, :unpublished

  define_fetch_method :open_flags, :count_open_flags

  def card
    return @card if @card
    if record_id
      super
    else
      @card = card_without_record_id
    end
    @card.record = self
    @card
  end

  def card_query
    { type: Card::RecordID, trash: false }
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

require_relative "record/active_record_extension"
Record.const_get("ActiveRecord_Relation").send :include, Record::ActiveRecordExtension