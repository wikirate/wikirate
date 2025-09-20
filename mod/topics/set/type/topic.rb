include_set Abstract::DeckorateTabbed
include_set Abstract::Thumbnail
include_set Abstract::Bookmarkable
include_set Abstract::Delist
include_set Abstract::CachedTypeOptions
include_set Abstract::SearchContentFields
include_set Abstract::StewardPermissions
include_set Abstract::JsonldSupported

card_accessor :image, type: :image
card_accessor :category, type: :pointer
card_accessor :topic_family, type: :pointer

card_accessor :subtopic, type: :search_type
card_accessor :dataset, type: :search_type
card_accessor :metric, type: :search_type

# require_field :topic_family, when: :topic_families?

def search_content_field_codes
  [:general_overview]
end

def topic_families?
  allowed_topic_families.present?
end

def framework_card
  left
end

def stewarded_card
  framework_card
end

def recursive_categories
  return [] unless (cat = category_card.first_card)

  [cat.id] + cat.recursive_categories
end

def determine_topic_family
  recursive_categories.last || id
end

def allowed_topic_families
  # @allowed_topic_families ||=
  left&.category_card&.item_ids || []
end
