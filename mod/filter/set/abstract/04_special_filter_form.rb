def virtual?
  true
end

include_set Set::Abstract::Filter

format :html do
  def filter_action_path
    path(mark: card.name.left, view: content_view)
  end

  view :core, cache: :never do
    filter_fields true
  end

  def content_view
    :data
  end
end
