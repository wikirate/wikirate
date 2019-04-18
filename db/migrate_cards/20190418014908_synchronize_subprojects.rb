# -*- encoding : utf-8 -*-

class SynchronizeSubprojects < Card::Migration
  def up
    Card.search(type_id: Card::ProjectID) do |project|
      %i[metric wikirate_company].each do |trait|
        trait_card = project.send "#{trait}_card"
        all_items = trait_card.item_names | trait_card.subproject_item_names
        trait_card.update_attributes! all_items.to_pointer_content
      end
    end
  end
end
