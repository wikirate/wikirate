# the following are the card ids of the SDG topics in order.
# Could also give them codenames...
SDG_TOPIC_IDS =
  [1094740, 1094743, 1094744, 1094771, 1094774, 1094777, 1094780, 1094784, 1094787,
   1099746, 1099750, 1099754, 1104669, 1104672, 1104675, 1104678, 1104681].freeze

SDG_OVERVIEW_ID = 1094739

def self.sdg_topic_names
  @sdg_topic_names ||= SDG_TOPIC_IDS.map(&:cardname).freeze
end

def self.sdg_overview_name
  @sdg_overview_name ||= SDG_OVERVIEW_ID.cardname || "sdg placeholder"
end

format :html do
  def custom_quick_filters
    haml :sdg_quick_filters, topic_ids: SDG_TOPIC_IDS
  end

  def sdg_topic_names
    SdgFiltering.sdg_topic_names
  end

  def sdg_label_link
    link_to_card SdgFiltering.sdg_overview_name, "SDGs:", target: "_blank"
  end

  def sdg_help_text
    "The Sustainable Development Goals (SDGs) are a group of 17 global goals <br/>" \
    'conceived as a "blueprint to achieve a better and more sustainable future".'
  end
end
