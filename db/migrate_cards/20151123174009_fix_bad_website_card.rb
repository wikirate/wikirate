# -*- encoding : utf-8 -*-

class FixBadWebsiteCard < Card::Migration
  def up
    bad_website_cards =
      Card.where("type_id = #{Card::PointerID} and name like '%+website'")
      .joins('LEFT JOIN card_actions on cards.id = card_actions.card_id')
      .where('card_actions.id is null')
    
    bad_website_cards.each do |website|
      content = website.content
      name = website.name
      Card::Auth.current_id = website.creator_id
      puts "recreate website #{website.name}".green
      website.delete
      Card.create! name: name, content: content
    end
  end
end
