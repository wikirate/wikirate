
format :html do
  view :editor, tags: :unknown_ok do
    _render_labeled_editor + " " +
      fa_icon("question-circle", title: "cannot find answer in source document")
  end
end
