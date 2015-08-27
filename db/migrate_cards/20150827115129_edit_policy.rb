# -*- encoding : utf-8 -*-

class EditPolicy < Card::Migration
  def up
    edit_policy_card = Card.create! :name=>"Edit Policy",:codename=>"edit_policy",:type_id=>Card::CardtypeID
    Card.create! :name=>"Edit Policy+*type+*structure",:type_id=>Card::HtmlID,:content=>"{{+description}}"
    Card.create! :name=>"Designer Assessed",:type_id=>edit_policy_card.id
    Card.create! :name=>"Designer Assessed+description",:type_id=>Card::BasicID,:content=>"Only the metric's designer may assess company values"
    Card.create! :name=>"Community Assessed",:type_id=>edit_policy_card.id
    Card.create! :name=>"Community Assessed+description",:type_id=>Card::BasicID,:content=>"Community members are invited to assess company values according to the prescribed methodology."
    Card.search(:type_id=>Card::MetricID).each do |metric_card|
      Card.create! :name=>"#{metric_card.name}+edit_policy",:type_id=>Card::PointerID,:content=>"[[Designer Assessed]]"
    end

  end
end
