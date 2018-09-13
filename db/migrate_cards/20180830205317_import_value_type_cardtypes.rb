# -*- encoding : utf-8 -*-

class ImportValueTypeCardtypes < Card::Migration
  def up
    fix_bad_test_data
    fix_record_types
    fix_answer_types
    Card::Cache.reset_all
    import_cards 'value_type_cardtypes.json'
    update_value_cardtypes
  end

  def fix_bad_test_data
    ensure_type_id_if_exists "Global Reporting Initiative+" \
                             "Fuel consumption from non-renewable sources (G4-EN3-a)",
                             Card::MetricID
    ensure_type_id_if_exists "AT&T Inc.", Card::WikirateCompanyID
  end

  def ensure_type_id_if_exists name, type_id
    return unless (card = Card[name]) && card.type_id != type_id
    card.update_column :type_id, type_id
  end

  def fix_record_types
    ensure_type Card::RecordID, Card::MetricID, Card::WikirateCompanyID
  end

  def fix_answer_types
    ensure_type Card::MetricAnswerID, Card::RecordID, Card::YearID
  end

  def ensure_type type_id, left_type_id, right_type_id
    Card.search left: { type_id: left_type_id },
                right: { type_id: right_type_id },
                type_id: [:ne, type_id] do |broken|
      puts "fixing #{Card.fetch_name(type_id)} #{broken.name}"
      broken.update_column :type_id, type_id
    end
  end

  def update_value_cardtypes
    Card.search(type_id: Card::MetricID) do |metric|
      if metric.relationship?
        bulk_update_types standard_value_ids(metric), Card::NumberValueID
      end
      bulk_update_types value_ids_for_metric(metric), metric.value_cardtype_id
    end
  end

  def value_ids_for_metric metric_card
    case metric_card.metric_type_codename
    when :score                ; score_value_ids metric_card
    when :relationship         ; relationship_value_ids metric_card
    when :inverse_relationship ; nil
    else                         standard_value_ids metric_card
    end
  end

  def score_value_ids metric_card
    value_ids_for_answers_where left: { left: { left_id: metric_card.id} },
                                type_id: Card::MetricAnswerID
  end

  def standard_value_ids metric_card
    value_ids_for_answers_where left: { left_id: metric_card.id },
                                type_id: Card::MetricAnswerID
  end

  def relationship_value_ids metric_card
    value_ids_for_answers_where left: { left: { left_id: metric_card.id} },
                                type_id: Card::RelationshipAnswerID
  end

  def value_ids_for_answers_where wql
    answer_ids = id_search wql
    return if answer_ids.blank?
    id_search right_id: Card::ValueID, left_id: answer_ids
  end

  def id_search wql
    Card.search wql.merge(limit: 0, return: :id)
  end

  def bulk_update_types ids, type_id
    return if ids.blank?
    Card.where(id: ids).update_all type_id: type_id
  end
end
