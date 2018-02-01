
format :html do
  view :research_form, cache: :never, perms: :update, tags: :unknown_ok do
    voo.editor = :inline_nests
    with_nest_mode :edit do
      card_form :create, class: "new-value-form",
                         "main-success" => "REDIRECT",
                         "data-slot-selector": ".card-slot.left_research_side-view",
                         success: research_form_success  do
        haml :research_form
      end
    end
  end

  def research_params
    voo.live_options[:research_params] ||
      { metric: metric, company: company, year: year }
  end

  def research_form_success
    research_params.merge id: ":research_page", soft_redirect: true,
                          view: :left_research_side, slot: { title: "Answer" }
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
    tags["card[name]"] = card.name
    # tags["card[subcards][+metric][content]"] = card.metric
    tags["card[type_id]"] =
      card.metric_card.relationship? ? RelationshipAnswerID : MetricValueID
    # tags["card[subcards][+source][content]"] = source if source.present?
    hidden_tags tags
  end

  def project
    @project ||= voo&.live_options[:project] ||
                 Env.params[:project] || Env.params["project"]
  end

  view :source_tab, cache: :never, tags: :unknown_ok, template: :haml do
    # unknown_ok tag doesn't work without this block
  end
end
