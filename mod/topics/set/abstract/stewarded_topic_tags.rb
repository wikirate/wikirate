event :validate_topic_stewardship, :validate, changed: :content do
  changed_item_cards.each do |topic|
    next if topic.framework_card.ok_as_steward?

    errors.add :permission_denied, "cannot change stewarded topic: #{topic.name}"
  end
end
