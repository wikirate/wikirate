# -*- encoding : utf-8 -*-

class ImportValueTypeCardtypes < Card::Migration
  ANSWER_TYPE_IDS = [Card::MetricAnswerID, Card::RelationshipAnswerID]

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
    each_answer_value do |value_card|
      value_card.update_attributes! type_id: type_id_for(value_card)
    end
  end

  def type_id_for value_card
    Card::Codename.id type_code_for(value_card)
  end

  def type_code_for value_card
    value_card.metric_card.value_cardtype_code
  rescue
    :free_text_value
  end

  def each_answer_value
    Card.where(right_id: Card::ValueID).find_each do |card|
      if ANSWER_TYPE_IDS.member? card.left.&type_id
        card.include_set_modules
        yield card
      else
        # binding.pry if card.name.parts.size > 2
      end
    end
  end
end
