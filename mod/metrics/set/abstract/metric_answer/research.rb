format :html do
  RESEARCH_PARAMS_KEY = :rp

  view :new, cache: :never do
    # @form_root = true
    nest :research_page, view: :slot_machine
  end

  def menu_item_edit opts
    super opts.merge(path: { RESEARCH_PARAMS_KEY => research_params }, remote: false)
  end

  view :year_edit_link do
    link_to_view :edit_year, fa_icon(:edit),
                 path: { RESEARCH_PARAMS_KEY => research_params },
                 remote: true,
                 class: "slotter _edit-year-link",
                 "data-slot-selector": ".card-slot.left_research_side-view > div > "\
                                       ".card-slot.TYPE-metric_answer"
  end

  view :edit do
    Env.params[:metric] = card.metric
    Env.params[:company] = card.company
    Env.params[:year] = card.year
    nest :research_page, view: :edit
  end

  view :research_edit_form, cache: :never, perms: :update, tags: :unknown_ok do
    return not_researchable unless card.metric_card.researchable?
    # voo.editor = :inline_nests
    with_nest_mode :edit do
      wrap do
        card_form :update,
                  "main-success" => "REDIRECT",
                  "data-slot-selector": ".card-slot.slot_machine-view",
                  success: research_form_success.merge(view: :slot_machine) do
          output [edit_view_hidden, _render_content_formgroup]
        end
      end
    end
  end

  def not_researchable
    "Answers to this metric cannot be researched directly. "\
    "They are calculated from other answers."
  end

  view :research_form, cache: :never, perms: :update, tags: :unknown_ok do
    research_form(:create) { haml :research_form }
  end

  view :edit_year, cache: :never, perms: :update do
    wrap { [edit_year_form, render_titled(hide: :menu)] }
  end

  def standard_cancel_button args={}
    args[:href] = path view: :titled if @slot_view == :edit_year
    super args
  end

  def edit_year_form
    return not_researchable unless card.metric_card.researchable?
    research_form(:update) { haml :edit_year_form  }
  end

  def research_form action
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

  def menu_link_path_opts
    super.merge RESEARCH_PARAMS_KEY => research_params
  end

  def research_params
    @research_params ||=
      inherit(:research_params) ||
      Env.params[RESEARCH_PARAMS_KEY]&.to_unsafe_h ||
      { metric: card.metric, company: card.company, year: card.year }
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
      card.metric_card.relationship? ? RelationshipAnswerID : MetricAnswerID
    # tags["card[subcards][+source][content]"] = source if source.present?
    hidden_tags tags
  end

  def project
    # FIXME: param keys should be standardized (probably symbols)
    @project ||= inherit(:project) || Env.params[:project] || Env.params["project"]
  end

  view :source_tab, cache: :never, tags: :unknown_ok, template: :haml do
    # unknown_ok tag doesn't work without this block
  end
end
