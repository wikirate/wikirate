format :html do
  RESEARCH_PARAMS_KEY = :rp

  def layout_name_from_rule
    :wikirate_two_column_layout
  end

  view :new, cache: :never do
    # @form_root = true
    nest :research_page, view: :slot_machine
  end

  def handle_research_params
    Env.params[:metric] = card.metric
    Env.params[:company] = card.company
    Env.params[:year] = card.year
    if card.respond_to?(:related_company)
      Env.params[:related_company] = card.related_company
    end
  end

  def bridge_parts
    handle_research_params
    with_nest_mode :normal do
      render_titled
    end
  end

  def researchably
    if card.metric_card.researchable?
      yield
    else
      not_researchable
    end
  end

  def not_researchable
    "Answers to this metric cannot be researched directly. "\
    "They are calculated from other answers."
  end

  view :research_form, cache: :never, perms: :update, tags: :unknown_ok do
    research_form(:create) { haml :research_form }
  end

  def cancel_research_button
    link_to "Cancel", path: research_params,
                      class: "btn btn-sm cancel-button btn-secondary"
  end

  def standard_cancel_button args={}
    args[:href] =
      if @slot_view == :edit_year
        edit_year_cancel_button_path
      else
        path view: :titled
      end

    super args
  end

  def research_form action
    researchably do
      voo.editor = :inline_nests
      with_nest_mode :edit do
        card_form action,
                  class: "new-value-form",
                  "main-success": "REDIRECT",
                  "data-slot-selector": ".card-slot.left_research_side-view",
                  success: research_form_success do
          yield
        end
      end
    end
  end

  view :content_formgroup, template: :haml do
    card.add_subfield :year, content: card.year
    if card.metric_card.relationship?
      card.add_subfield :related_company, content: card.related_company
    end
  end

  def card_form_html_opts action, opts={}
    super
    add_class opts, "answer-form"
    opts
  end

  view :year_edit_link do
    link_to_view :edit_year, menu_icon,
                 path: { RESEARCH_PARAMS_KEY => research_params },
                 class: "_edit-year-link text-dark",
                 "data-slot-selector": ".card-slot.left_research_side-view > div > "\
                                       ".card-slot.TYPE-metric_answer"
  end

  def menu_link
    bridge_link + super
  end

  def edit_link view=:edit, _opts={}
    link_to menu_icon, path: research_params.merge(view: view), class: "edit-answer-link"
  end

  def research_params
    @research_params ||= inherit(:research_params) ||
                         prefixed_research_params ||
                         default_research_params
  end

  def prefixed_research_params
    @prefixed_research_params ||= Env.params[RESEARCH_PARAMS_KEY]&.to_unsafe_h
  end

  def default_research_params
    hash = { metric: card.metric, company: card.company, year: card.year }
    hash[:project] = project if project.present?
    hash
  end

  def research_form_success
    research_params.merge id: ":research_page", redirect: true, view: :slot_machine
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
      card.metric_card.relationship? ? RelationshipAnswerID : MetricAnswerID
    # tags["card[subcards][+source][content]"] = source if source.present?
    hidden_tags tags
  end

  def project
    # FIXME: param keys should be standardized (probably symbols)
    @project ||= inherit(:project) ||
                 Env.params[:project] || Env.params["project"] ||
                 (prefixed_research_params && prefixed_research_params[:project])
  end
end
