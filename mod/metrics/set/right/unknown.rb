
format :html do
  view :editor, tags: :unknown_ok do
    _render_labeled_editor + popover_link("cannot find answer in source document")
  end
end
