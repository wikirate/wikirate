# module for project-scope-definining cards
# (+company, +metric, and +year on projects)

# @return [Card::Name]
def project_name
  name.left_name
end

def project_card
  Card[project_name]
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

# @return [Card] a single (Right name)+<Project> card. Configured in Ltype-Rtype set.
def item_project_card item_card
  Card.fetch item_card.name, project_name, new: {}
end

def all_item_project_cards
  valid_item_cards.map do |item|
    item_project_card item
  end
end

def add_to_parent?
  !parent_project.nil?
end

def parent_project
  @parent_project ||= project_card.parent_project_card
end

# eg, <Parent Project>+metric
def parent_field
  @parent_field ||= parent_project.send "#{Card::Codename[right_id]}_card"
end

def union_with_parent_field
  parent_field.item_names | item_names
end

event :add_items_to_parent_project, :integrate, on: :save do
  return unless add_to_parent?
  add_subcard parent_field.name, content: union_with_parent_field.to_pointer_content
end
