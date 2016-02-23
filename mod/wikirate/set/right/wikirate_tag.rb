event :create_missing_tags, :finalize, on: :save do
  new_tags = item_names
  new_tags.each do |tag|
    next if Card.exists? tag
    add_subcard tag, type_id: Card::WikirateTagID
  end
end
