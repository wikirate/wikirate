include_set Abstract::IdList
include_set Abstract::StewardedTopicTags

assign_type :list

def framework_names
  item_names.map {|n| n.trunk_name }.uniq
end

format :html do
  def input_type
    :framework_tree
  end

  def framework_tree_input
    haml :framework_tree_input
  end

  before :core do
    @frameworks = card.framework_names
  end

  def wrap_item item_card, rendered, item_view
    group = @frameworks.index item_card.name.trunk_name
    %(<div class="pointer-item item-#{item_view} item-group-#{group}">) +
      %(#{rendered}</div>)
  end
end
