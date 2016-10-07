# include_set Abstract::SolidCache, cached_format: :json
#
# ensure_set { Metric::WikirateTopic::TypePlusRight }
#
# cache_update_trigger Metric::WikirateTopic::TypePlusRight,
#                      on: :update do |changed_card|
#   for each changed card (eg. CDP+Climate Score+topic)
#   take metric from left, find all companies with record
#   return +all topics for those
#   changed_card.changed_item_cards
# end
#
# ensure_set { Metric::WikirateCompany::LTypeRType }
# cache_update_trigger Metric::WikirateCompany::LTypeRType,
#                      on: :save do |changed_card|
#
#   res = [changed_card.cardname.right]
#   if changed_card.name_changed?
#     res << changed_card.name_was
#   end
#   res.map { |name| Card.fetch(name, :all_topics) }.compact
# end



