include_set Abstract::IdList
include_set Abstract::StewardedTopicTags

assign_type :list

format :html do
  def input_type
    :framework_tree
  end

  def framework_tree_input
    haml :framework_tree_input
  end
end
