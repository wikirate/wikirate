# include_set Abstract::CompanySearch
#
# # cache # of companies related to this topic (=left) via answer for metrics that
# # are tagged with this topic
# include_set Abstract::AnswerLookupCachedCount, target_type: :company
#
# def query_hash
#   { topic: left_id }
# end
#
# def topic_name
#   name.left_name
# end
#
# # when answer is created/deleted
# recount_trigger :type, :answer, on: %i[create delete] do |changed_card|
#   company_cache_cards_for_answer changed_card
# end
#
# # ...or when answer is (un)published
# field_recount_trigger :type_plus_right, :answer, :unpublished do |changed_card|
#   company_cache_cards_for_answer changed_card.left
# end
#
# # ... when <metric>+topic is edited
# recount_trigger :type_plus_right, :metric, :topic do |changed_card|
#   company_cache_cards_for_topics changed_card.changed_item_names
# end
#
# class << self
#   def company_cache_cards_for_answer answer
#     company_cache_cards_for_topics topic_names_for_answer(answer)
#   end
#
#   def topic_names_for_answer answer
#     answer.metric_card&.topic_card&.item_names
#   end
#
#   def company_cache_cards_for_topics topic_names
#     topic_names.map do |topic_name|
#       # TODO: confirm all +topic items are valid topics so this check isn't necessary
#       # (validation is in place)
#       next unless Card.fetch_type_id(topic_name) == TopicID
#       Card.fetch topic_name, :company
#     end.compact
#   end
# end
