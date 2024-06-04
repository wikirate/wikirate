format :html do
  def filter_buttons
    super << :customize_filtered_button
  end

  view :customize_filtered_button, template: :haml
end
