
format :html do
  view :editor, tags: :unknown_ok do
    _render_labeled_editor +
      link_to(fa_icon("question-circle"),
              class: "pl-1", path: "#",
              "data-toggle": "popover",
              "data-content": "cannot find answer in source document")
  end
end
