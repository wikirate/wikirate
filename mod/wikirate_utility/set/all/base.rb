
format :html do
  def default_nest_view
    :content
  end
end

format do
  view :paragraph do
    Card::Content.smart_truncate _render_core, words = 100
  end

  view :preview do
    Card::Content.smart_truncate _render_core, words = 40
  end
end
