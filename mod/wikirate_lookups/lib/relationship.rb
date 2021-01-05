# Lookup table for relationship answers to relationship metrics
class Relationship < ApplicationRecord
  @card_column = :relationship_id
  @card_query = {  type_id: Card::RelationshipAnswerID, trash: false }

  include LookupTable
  include EntryFetch
  include Csv

  after_destroy :latest_to_true
  delegate :company_id, :designer_id, :title_id, to: :answer
  fetcher :answer_id, :value, :numeric_value, :imported

  # other relationships in same record
  def record_relationships
    Relationship
      .where(subject_company_id: subject_company_id, metric_id: metric_id)
      .where.not(id: id)
  end

  def latest_year_in_db
    # (object_company_id: object_company_id)
    record_relationships.maximum :year
  end

  def latest_to_false
    record_relationships.where(latest: true).update_all latest: false
  end

  def latest_to_true
    return unless (latest_year = latest_year_in_db)

    record_relationships.where(year: latest_year, latest: false).update_all latest: true
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

  def delete_on_refresh?
    super() || (!metric_card&.hybrid? && invalid?)
    # when we override a hybrid metric the answer is invalid because of the
    # missing answer_id, so we check `invalid?` only for non-hybrid metrics)
  end

  private

  def metric_card
    @metric_card ||= Card[metric_id]
  end

  def metric_name
    metric_id.cardname
  end

  def subject_company_name
    subject_company_id.cardname
  end

  def object_company_name
    object_company_id.cardname
  end

  def unknown? val
    Answer.unknown? val
  end
end
