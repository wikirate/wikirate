def content_for_search
  fetch(:aliases)&.item_names&.join " "
end
