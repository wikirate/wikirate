# Lookup table for relationships structured by relation metrics
class Relationship < Cardio::Record
  @card_column = :relationship_id

  include LookupTable

  include EntryFetch
  include Export
  include Answer::AndRelationship

  extend FilterHelper

  delegate :company_id, :designer_id, :title_id, to: :answer
  fetcher :answer_id, :metric_id, :record_id, :value, :numeric_value

  belongs_to :metric, primary_key: :metric_id

  def card_query
    { type_id: Card::RelationshipID, trash: false }
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
