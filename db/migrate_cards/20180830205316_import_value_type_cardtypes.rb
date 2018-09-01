# -*- encoding : utf-8 -*-

class ImportValueTypeCardtypes < Card::Migration
  TYPE_IDS = [Card::MetricAnswerID, Card::RelationshipAnswerID]

  def up
    import_cards 'value_type_cardtypes.json'
    update_value_cardtypes
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
      # not super efficient querying, but without batches
      # this will probably bog down the server.

      # yield card if TYPE_IDS.member? card.left.type_id
      # above not working because answers don't have the right type??

      next unless card.name.parts.size > 2
      card.include_set_modules
      yield card
    end
  end
end
