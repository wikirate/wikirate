format :html do
  view :research_form, cache: :never, perms: :update, tags: :unknown_ok do
    voo.editor = :inline_nests
    with_nest_mode :edit do
      card_form :create, class: "new-value-form",
                         "main-success" => "REDIRECT",
                         success: research_form_success  do
        haml :research_form
      end
    end
  end

  def research_form_success
    { id: "_self", soft_redirect: true, view: :titled }
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
    tags["card[subcards][+source][content]"] = source if source.present?
    hidden_tags tags
  end
end
