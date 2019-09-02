# format :html do
#   def metric_row header, data
#     item_class = args[:item_types].map { |t| "#{t}-item" }.join " "
#     inner = wrap_with(:div, header, class: "header") +
#             wrap_with(:div, data, class: "data")
#
#     content = wrap_with :div do
#       wrap_with(:div, inner, class: item_class) +
#         wrap_with(:div, "", class: "details")
#     end
#     process_content content
#   end
# end
