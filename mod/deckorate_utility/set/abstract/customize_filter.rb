format :html do
  def filter_buttons
    super.insert 1, :customize_filtered_button
  end

  view :customize_filtered_button, template: :haml
end
