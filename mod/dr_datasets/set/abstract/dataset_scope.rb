include_set Abstract::PointerCachedCount

# module for dataset-scope-defining cards
# (+company, +metric, and +year on datasets)

# @return [Card::Name]
def dataset_name
  name.left_name
end

def dataset_card
  left
end

# only returns items with the correct type
def valid_item_cards
  @valid_item_cards ||= item_cards_for_validation.select do |item|
    item.type_id == right_id
  end
end

def valid_item_names
  valid_item_cards.map(&:name)
end

def valid_item_ids
  valid_item_cards.map(&:id)
end

def num
  valid_item_cards.size
end

# overridable method (eg to change sort order)
def item_cards_for_validation
  item_cards
end

def hereditary_field?
  true
end

def add_to_parent?
  hereditary_field? && !parent_dataset.nil?
end

def parent_dataset
  @parent_dataset ||= dataset_card.parent_dataset_card
end

# eg, <Parent Dataset>+metric
def parent_field
  @parent_field ||= relative_dataset_field(parent_dataset)
end

# eg return :wikirate_company on +Company cards
def scope_code
  name.right_name&.codename
end

# same field, different dataset
def relative_dataset_field relative_dataset
  relative_dataset.send "#{scope_code}_card"
end

def union_with_parent_field
  parent_field.item_names | item_names
end

def data_subset_item_names
  dataset_card.data_subset_card.item_cards.map do |data_subset|
    relative_dataset_field(data_subset).item_names
  end.flatten.uniq
end

event :add_items_to_parent_dataset, :integrate, on: :save do
  return unless add_to_parent?
  add_subcard parent_field.name, content: union_with_parent_field.to_pointer_content
end

def missing_data_subset_item_names
  data_subset_item_names.select do |name|
    !item_names.include? name
  end
end

event :validate_all_data_subset_items_present, :validate, on: :update do
  return unless hereditary_field?
  missing_names = missing_data_subset_item_names
  return unless missing_names.present?

  errors.add :content, "The following are still associated with data_subsets " \
                       "and cannot be removed: #{missing_names.join ', '}"
end

event :prevent_deletion_if_data_subset_items_present, :validate, on: :delete do
  return unless hereditary_field? && data_subset_item_names.present?

  errors.add :content, "This card cannot be deleted, because there are data_subsets " \
                       "with at least one #{scope_code.cardname}"
end

format :html do
  def filtered_list_input
    voo.items = { view: :thumbnail }
    super
  end

  def input_type
    card.count > 500 ? :list : :filtered_list
  end

  def filter_card
    Card.fetch card.scope_code, filter_field_code
  end
end
