include_set Abstract::ListCachedCount

# module for dataset-scope-defining cards
# (+company, +metric, and +year on datasets)

def item_names _args={}
  super.sort_by(&:key)
end

# eg +:metric must contain only :metric
def ok_item_types
  right_id
end

# @return [Card::Name]
def dataset_name
  name.left_name
end

def dataset_card
  left
end

def num
  item_cards.size
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

# eg return :company on +Company cards
def scope_code
  name.right_name&.codename
end

# same field, different dataset
def relative_dataset_field relative_dataset
  relative_dataset.send "#{scope_code}_card"
end

def union_with_parent_field
  parent_field.item_ids | item_ids
end

def data_subset_item_ids
  dataset_card.data_subset_card.item_cards.map do |data_subset|
    relative_dataset_field(data_subset).item_ids
  end.flatten.uniq
end

event :add_items_to_parent_dataset, :integrate, on: :save do
  return unless add_to_parent?
  subcard parent_field.name, content: union_with_parent_field
end

def missing_data_subset_item_ids
  data_subset_item_ids - item_ids
end

event :validate_all_data_subset_items_present, :validate, on: :update do
  return unless hereditary_field? && (missing_ids = missing_data_subset_item_ids).present?
  missing_names = missing_ids.map(&:cardname)

  errors.add :content, "The following are still associated with data_subsets " \
                       "and cannot be removed: #{missing_names.join ', '}"
end

event :prevent_deletion_if_data_subset_items_present, :validate, on: :delete do
  return unless hereditary_field? && data_subset_item_ids.present?

  errors.add :content, "This card cannot be deleted, because there are data_subsets " \
                       "with at least one #{scope_code.cardname}"
end

format :html do
  def filtered_item_view
    :thumbnail
  end

  def input_type
    card.count > 200 ? :list : :filtered_list
  end

  def filter_card
    card.scope_code.card
  end
end
