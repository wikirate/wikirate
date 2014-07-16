
event :create_missing_tags, :after=>:store, :on=>:save do

  new_right_tag = Card[name]
  new_tags = new_right_tag.item_cards
  new_tags.each do |tag|
    new_tag_name = tag.name
    if !Card.exists? new_tag_name  
      Card.create! :type_id=>Card::WikirateTagID, :name=>new_tag_name
    end
  end
  
end