format :html do
  # table with existing values
  # and source side for adding new values
  view :research_answer do
    #voo.show! :answer_form
    voo.editor = :inline_nests
    frame do
      render_haml :research_answer
    end
  end

  # slot for the form
  view :new_answer, cache: :never do
    wrap do
      _optional_render :answer_form
    end
  end

  view :answer_form do
    voo.editor = :inline_nests
    with_nest_mode :edit do
      relative_card_form :create, "main-success" => "REDIRECT",
                         class: "new-value-form",
                         success: { id: "_left",
                                    soft_redirect: true,
                                    view: :new_answer_success } do
        render_haml(:table_editor)
      end
    end
  end

  def source_form_url
    path action: :new, mark: :source, preview: true, company: card.company
  end

  def new_buttons
    button_formgroup do
      [
        submit_button(disable_with: "Adding..."),
        button_tag("Close", class: "_form_close_button")
      ]
    end
  end

  def answer_form_hidden_tags
    tags = {}
    tags["card[subcards][+company][content]"] = card.company
    tags["card[subcards][+metric][content]"] = card.metric
    tags["card[type_id]"] = MetricValueID
    tags["card[subcards][+source][content]"] = source if source.present?
    hidden_tags tags
  end

  def source
    Env.params[:source]
  end

  def sources
    @sources ||= find_potential_sources
    if source && (source_card = Card[source])
      @sources.push(source_card)
    end
    @sources
  end

  view :relevant_sources, cache: :never do
    wrap_with :div, source_list.html_safe, class: "relevant-sources"
  end

  def source_list
    return "None" if sources.empty?
    sources.map do |source|
      with_nest_mode :normal do
        subformat(source).render_relevant
      end
    end.join("")
  end

  def find_potential_sources
    Card.search(
      type_id: Card::SourceID,
      right_plus: [["company", { refer_to: card.company }],
                   ["report_type", {
                     refer_to: {
                       referred_to_by: card.metric + "+report_type" } }]]
    )
  end

  def view_template_path view
    super(view, __FILE__)
  end
end
