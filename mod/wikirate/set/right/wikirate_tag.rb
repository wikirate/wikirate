event :create_missing_tags, :after=>:store, :on=>:save do
  
  new_tags = self.item_names
  new_tags.each do |tag|
    if !Card.exists? tag  
      Card.create! :type_id=>Card::WikirateTagID, :name=>tag
    end
  end
  
end