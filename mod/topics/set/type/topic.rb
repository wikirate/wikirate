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

event :validate_topic_category, :validate, when: :restricted_top_categories? do
  return if top_category.in? allowed_top_categories

  top_cats = allowed_top_categories.to_sentence last_word_connector: ", or "
  errors.add :content, "top category must be one of #{top_cats}"
end

def search_content_field_codes
  [:general_overview]
end

def top_category
  recursive_categories.last || name
end

def restricted_top_categories?
  allowed_top_categories.present?
end

def recursive_categories
  return [] unless (cat = category_card.first_card)

  [cat.name] + cat.recursive_categories
end

private

def allowed_top_categories
  @allowed_top_categories ||= determine_allowed_top_categories
end

def determine_allowed_top_categories
  topic_framework_card(true)&.first_card&.category_card&.item_names || []
end
