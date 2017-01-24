format :html do
  view :table_form, cache: :never do
    binding.pry
    voo.editor = :inline_nests
    card_form :create, "main-success" => "REDIRECT",
              class: "new-value-form" do
      output [
               new_view_hidden,
               new_view_type,
               haml_view(:table_editor)
             ]
    end
  end

  view :new_buttons do
    button_formgroup do
      wrap_with :div do
        [
          table_submit_button,
          table_close_button
        ]
      end
    end
  end

  def table_submit_button
    submit_button class: "create-submit-button",
                  data: { disable_with: "Adding..." }
  end

  def table_close_button
    wrap_with :button, "Close",
              type: "button",
              class: "btn btn-default _form_close_button"
  end

  def new_view_hidden
    tags =
      { success: { id: "_self", soft_redirect: true, view: :record_list } }
    [:metric, :company, :source].each do |field|
      next unless (value = Env.params[field])
      tags["card[subcards][+#{field}][content]"] = value
    end
    hidden_tags tags
  end

  view :relevant_sources, cache: :never do
    sources =
      find_potential_sources(Env.params[:company] || card.company,
                             Env.params[:metric] || card.metric)
    if (source_name = Env.params[:source]) && (source_card = Card[source_name])
      sources.push(source_card)
    end
    relevant_sources =
      if sources.empty?
        "None"
      else
        sources.map do |source|
          with_nest_mode :normal do
            subformat(source).render_relevant
          end
        end.join("")
      end
    wrap_with(:div, relevant_sources.html_safe, class: "relevant-sources")
  end

  def find_potential_sources company, metric
    Card.search(
      type_id: Card::SourceID,
      right_plus: [["company", { refer_to: company }],
                   ["report_type", {
                     refer_to: {
                       referred_to_by: metric + "+report_type" } }]]
    )
  end

  def view_template_path view
    super(view, __FILE__)
  end
end
