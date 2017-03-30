format :html do
  view :new, cache: :never do
    @form_root = true
    subformat(Card[:research_page])._render_new
  end

  view :content_formgroup, cache: :never do
    voo.hide :name_formgroup, :type_formgroup
    prepare_nests_editor
    super()
  end

  def prepare_nests_editor
    voo.editor = :nests
    card.add_subfield :year, content: card.year
    voo.edit_structure = [[:value, "Value"], [:year, "Year"]]
  end

  def default_new_args _args
    metric_name = Env.params[:metric]
    voo.title = "Add new value for #{metric_name}" if metric_name
  end
end
