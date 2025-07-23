include_set Abstract::IdList

assign_type :pointer

delegate :determine_topic_family, :allowed_topic_families, :topic_families?, to: :topic

event :validate_topic_family, :validate,
      on: :save, changed: :content, when: :topic_families? do
  self.content = [determine_topic_family]
  return if content.in? allowed_topic_families

  errors.add :content,
             "category must be in one of these families: " +
             (allowed_topic_families.map(&:cardname)
                                    .to_sentence last_word_connector: ", or ")
end

def history?
  false
end

def topic
  left
end

def refresh_topic_family
  if (family = determine_topic_family).present?
    update content: [family]
  elsif real?
    delete
  end
end

# event :update_metric_topic_families, :integrate, changed: :content do
#   left.metric_card.item_cards.each do |metric|
#     metric.fetch(topic.topic_framework, new: {}).refresh_families
#   end
# end
