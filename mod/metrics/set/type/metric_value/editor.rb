format :html do
  view :new, cache: :never do
    @form_root = true
    subformat(Card[:research_page])._render_new
  end

  def default_edit_args args
    # voo.hide! :toolbar
    voo.hide! :edit_buttons
  end

  view :content_formgroup, template: :haml do
    card.add_subfield :year, content: card.year
  end

  def default_new_args _args
    metric_name = Env.params[:metric]
    voo.title = "Add new value for #{metric_name}" if metric_name
  end
end
