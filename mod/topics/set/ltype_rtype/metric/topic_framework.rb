# include_set Abstract::IdList
#
# # for each framework with topic families (including the Wikriate ESG family)
# # we store a list of families that apply to a given metric whenever:
#
# # 1. Metric+topic is changed (update for all changed frameworks)
# # 2. Topic+Topic Family is changed (update for framework)
#
# assign_type :list
#
# def metric
#   left
# end
#
# def topic_framework
#   right
# end
#
# def history?
#   false
# end
#

#
# private
#
# def family_ids
#   return unless topics.present?
#
#   Card.search referred_to_by: { left: [:in] + topics.map(&:id), right: :topic_family },
#               return: :id
# end
#
# def topics
#   @topics ||= metric.topic_card.item_cards_by_framework topic_framework.id
# end
