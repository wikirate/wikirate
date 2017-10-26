# To be included in a field card to get a filter for the parent.
# The core view renders a filter for the left card.

include_set Set::Abstract::Filter

def virtual?
  true
end

format :html do
  def filter_action_path
    path mark: card.name.left, view: filter_view
  end

  view :core, cache: :never do
    filter_fields
  end

  def filter_view
    :data
  end
end
