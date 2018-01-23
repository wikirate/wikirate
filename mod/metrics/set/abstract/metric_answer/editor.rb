format :html do
  view :new, cache: :never do
    @form_root = true
    subformat(Card[:research_page])._render_core
  end

  def default_edit_args _args
    # voo.hide! :toolbar
    voo.hide! :edit_buttons
  end

  view :source_side, template: :haml

  view :content_formgroup, template: :haml do
    card.add_subfield :year, content: card.year
    if card.metric_card.relationship?
      card.add_subfield :related_company, content: card.related_company
    end
  end

  view :source_side, template: :haml

  def default_new_args _args
    metric_name = Env.params[:metric]
    voo.title = "Add new value for #{metric_name}" if metric_name
  end
end
