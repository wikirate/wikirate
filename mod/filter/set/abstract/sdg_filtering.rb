SDG_TOPIC_IDS =
  [1094740, 1094743, 1094744, 1094771, 1094774, 1094777, 1094780, 1094784, 1094787,
   1099746, 1099750, 1099750, 1104669, 1104672, 1104675, 1104678, 1104681].freeze

format :html do
  def custom_quick_filters
    haml :sdg_quick_filters, topic_ids: SDG_TOPIC_IDS
  end

  def sdg_help_text
    "The Sustainable Development Goals (SDGs) are a group of 17 global goals <br/>" \
    'conceived as a "blueprint to achieve a better and more sustainable future".'
  end
end
