
format :html do
  view :editor, unknown: true do
    _render_labeled_editor + popover_link("cannot find answer in source document")
  end
end
