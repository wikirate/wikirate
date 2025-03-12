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

event :validate_topic_family, :validate, when: :topic_families? do
  family = determine_topic_family
  return if family.in? allowed_topic_families

  families = allowed_topic_families.to_sentence last_word_connector: ", or "
  errors.add :content, "category must be in one of these families #{families}"
end

def search_content_field_codes
  [:general_overview]
end

def topic_families?
  allowed_topic_families.present?
end

def recursive_categories
  return [] unless (cat = category_card.first_card)

  [cat.name] + cat.recursive_categories
end

def determine_topic_family
  recursive_categories.last || name
end

private

def allowed_topic_families
  @allowed_topic_families ||=
    topic_framework_card(true)&.first_card&.category_card&.item_names || []
end
