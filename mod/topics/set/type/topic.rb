include_set Abstract::DeckorateTabbed
include_set Abstract::Thumbnail
include_set Abstract::Bookmarkable
include_set Abstract::Delist
include_set Abstract::CachedTypeOptions
include_set Abstract::SearchContentFields

card_accessor :image, type: :image
card_accessor :category, type: :pointer
card_accessor :topic_framework, type: :pointer

card_accessor :subtopic, type: :search_type
card_accessor :dataset, type: :search_type
card_accessor :metric, type: :search_type

def search_content_field_codes
  [:general_overview]
end

def recursive_categories
  return [] unless (cat = category_card.first_card)

  [cat.name] + cat.recursive_categories
end

def top_category
  recursive_categories.last
end
