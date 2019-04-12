# module for project-scope-definining cards
# (+company, +metric, and +year on projects)

setting :scope_label

# @return [Card::Name]
def project_name
  name.left_name
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
