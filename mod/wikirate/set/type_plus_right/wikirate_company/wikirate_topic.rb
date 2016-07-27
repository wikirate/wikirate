# def raw_content
#   %(
#     {
#       "name":"home"
#     }
#   )
# end

# format do
#   def related_topic_from_source_or_note
#     Card.search(
#       type: "Topic",
#       referred_to_by: {
#         left: {
#           type: %w(in Note Source),
#           right_plus: ["company", refer_to: card.cardname.left]
#         },
#         right: "topic"
#       })
#   end

#   def related_topic_from_metric
#     Card.search(
#       type: "Topic",
#       referred_to_by: {
#         left: { type: "Metric", right_plus: card.cardname.left },
#         right: "topic"
#       })
#   end

#   def search_results _args={}
#     @search_results = super(search_results(_args))
#     binding.pry
#     @search_results
#   end
# end
