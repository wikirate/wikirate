include_set Abstract::DeckorateTabbed
include_set Abstract::Thumbnail
include_set Abstract::Bookmarkable
include_set Abstract::Delist
include_set Abstract::CachedTypeOptions
include_set Abstract::SearchContentFields

card_accessor :image, type: :image
card_accessor :category, type: :pointer
card_accessor :topic_framework, type: :pointer
card_accessor :topic_family, type: :pointer

card_accessor :subtopic, type: :search_type
card_accessor :dataset, type: :search_type
card_accessor :metric, type: :search_type

require_field :topic_family, when: :topic_families?

event :ensure_topic_family, :validate, on: :save, when: :topic_families? do
  subcard topic_family_card
end

def search_content_field_codes
  [:general_overview]
end

def topic_families?
  allowed_topic_families.present?
end

def family_framework
  topic_framework.card if topic_families?
end

def recursive_categories
  return [] unless (cat = category_card.first_card)

  [cat.id] + cat.recursive_categories
end

def determine_topic_family
  recursive_categories.last || id
end

private

def allowed_topic_families
  # @allowed_topic_families ||=
  left&.category_card&.item_ids || []
end
