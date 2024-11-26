# -*- encoding : utf-8 -*-

class ImportValueTypeCardtypes < Cardio::Migration::Transform
  def up
    fix_bad_test_data
    fix_answer_types
    fix_answer_types
    Card::Cache.reset_all
    import_cards 'value_type_cardtypes.json'
    update_value_cardtypes
  end

  def fix_bad_test_data
    ensure_type_id_if_exists "Global Reporting Initiative+" \
                             "Fuel consumption from non-renewable sources (G4-EN3-a)",
                             Card::MetricID
    ensure_type_id_if_exists "AT&T Inc.", Card::CompanyID
  end

  def ensure_type_id_if_exists name, type_id
    return unless (card = Card[name]) && card.type_id != type_id
    card.update_column :type_id, type_id
  end

  def fix_answer_types
    ensure_type Card::AnswerID, Card::MetricID, Card::CompanyID
  end

  def fix_answer_types
    ensure_type Card::AnswerID, Card::AnswerID, Card::YearID
  end

  def ensure_type type_id, left_type_id, right_type_id
    Card.search left: { type_id: left_type_id },
                right: { type_id: right_type_id },
                type_id: [:ne, type_id] do |broken|
      puts "fixing #{type_id.cardname} #{broken.name}"
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
                                type_id: Card::AnswerID
  end

  def standard_value_ids metric_card
    value_ids_for_answers_where left: { left_id: metric_card.id },
                                type_id: Card::AnswerID
  end

  def relationship_value_ids metric_card
    value_ids_for_answers_where left: { left: { left_id: metric_card.id} },
                                type_id: Card::RelationshipAnswerID
  end

  def value_ids_for_answers_where cql
    answer_ids = id_search cql
    return if answer_ids.blank?
    id_search right_id: Card::ValueID, left_id: answer_ids
  end

  def id_search cql
    Card.search cql.merge(limit: 0, return: :id)
  end

  def bulk_update_types ids, type_id
    return if ids.blank?
    Card.where(id: ids).update_all type_id: type_id
  end
end
