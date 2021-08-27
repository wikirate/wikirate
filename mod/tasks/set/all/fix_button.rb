view :fix_button do
  link_to_card card, "Fix Me", path: { view: :edit }, class: "btn btn-primary"
end

view :bar_and_fix_button, template: :haml
