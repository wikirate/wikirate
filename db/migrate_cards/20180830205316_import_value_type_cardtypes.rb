# -*- encoding : utf-8 -*-

class ImportValueTypeCardtypes < Card::Migration
  TYPE_IDS = [Card::MetricAnswerID, Card::RelationshipAnswerID]

  def up
    import_cards 'value_type_cardtypes.json'
    update_value_cardtypes
  end

  def update_value_cardtypes
    each_answer_value do |value_card|
      value_card.update_attributes! type_code: type_for(value_card)
    end
  end

  def type_for value_card
    # or maybe value_card.left.value_cardtype_code ?
    :"#{value_card.metric_card.value_type_code}_value"
  end

  def each_answer_value
    Card.where(right_id: Card::ValueID).find_each do |card|
      # not super efficient querying, but without batches
      # this will probably bog down the server.

      # yield card if TYPE_IDS.member? card.left.type_id
      # above not working because answers don't have the right type??

      yield card if card.name.parts.size > 2
    end
  end
end
