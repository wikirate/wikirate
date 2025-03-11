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

event :validate_category, :validate, when: :restricted_topic_families? do
  return if topic_family.in? allowed_topic_families

  top_cats = allowed_topic_families.to_sentence last_word_connector: ", or "
  errors.add :content, "category must be in one of these families #{top_cats}"
end

# event :assign_topic_family do
#
# end

def search_content_field_codes
  [:general_overview]
end

def topic_family
  recursive_categories.last || name
end

def restricted_topic_families?
  allowed_topic_families.present?
end

def recursive_categories
  return [] unless (cat = category_card.first_card)

  [cat.name] + cat.recursive_categories
end

private

def allowed_topic_families
  @allowed_topic_families ||= determine_allowed_topic_families
end

def determine_allowed_topic_families
  topic_framework_card(true)&.first_card&.category_card&.item_names || []
end
