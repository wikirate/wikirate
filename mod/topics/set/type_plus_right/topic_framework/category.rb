def topic_framework
  left
end

event :apply_family_restriction, :finalize, changed: :content do
  topic_framework.topic_card.item_cards.each do |topic|
    topic.topic_family_card.refresh_topic_family
  end
end
