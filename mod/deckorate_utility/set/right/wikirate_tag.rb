assign_type :list

event :create_missing_tags, :finalize, on: :save do
  item_names.each do |tag|
    next if Card.exists? tag
    subcard tag, type: :wikirate_tag
  end
end
