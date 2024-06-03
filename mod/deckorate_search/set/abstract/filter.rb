basket[:filter_buttons].insert 1, :customize_filtered_button

format :html do
  view :customize_filtered_button, template: :haml
end