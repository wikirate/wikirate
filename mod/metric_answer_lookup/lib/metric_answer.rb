class MetricAnswer < ActiveRecord::Base
  include LookupTable
  include Filter
  extend LookupTable::ClassMethods

  def card_column
    :metric_answer_id
  end

  def fetch_metric_answer_id
    card.id
  end

  def fetch_company_id
    card.left.right_id
  end

  def fetch_metric_id
    metric_card.id
  end

  def fetch_metric_record_id
    card.left_id
  end

  def fetch_metric_name
    card.cardname.left_name.left
  end

  def fetch_company_name
    card.cardname.left_name.right
  end

  def fetch_metric_record_name
    card.cardname.left
  end

  def fetch_year
    card.cardname.right.to_i
  end

  def fetch_imported
    false
  end

  def fetch_designer_id
    metric_card.left_id
  end

  def fetch_policy_id
    return unless (policy_pointer = metric_card.fetch(trait: :research_policy))
    policy_name = policy_pointer.item_names.first
    (pc = Card.quick_fetch(policy_name)) && pc.id
  end

  def fetch_metric_type_id
    return unless (metric_type_pointer = metric_card.fetch(trait: :metric_type))
    metric_type_name = metric_type_pointer.item_names.first
    (mtc = Card.quick_fetch(metric_type_name)) && mtc.id
  end

  def fetch_value
    card.value
  end

  def fetch_updated_at
    return card.updated_at unless (vc = card.value_card)
    [card.updated_at, vc.updated_at].compact.max
  end

  def fetch_latest
    return true unless (latest_year = latest_year_in_db)
    @new_latest = (latest_year < fetch_year)
    latest_year <= fetch_year
  end

  def latest_year_in_db
    MetricAnswer.where(metric_record_id: fetch_metric_record_id).maximum(:year)
  end

  def delete
    super.tap do
      if (latest_year = latest_year_in_db)
        MetricAnswer.where(metric_record_id: metric_record_id, year: latest_year)
            .update_all(latest: true)
      end
    end
  end

  def latest_to_false
    MetricAnswer.where(metric_record_id: metric_record_id, latest: true)
        .update_all(latest: false)
  end

  def latest= value
    latest_to_false if @new_latest
    super
  end

  private

  def metric_card
    @metric_card ||= Card.quick_fetch(fetch_metric_name)
  end
end
