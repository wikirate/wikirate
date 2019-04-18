format :html do
  RESEARCH_PARAMS_KEY = :rp

  def layout_name_from_rule
    :wikirate_two_column_layout
  end

  view :new, cache: :never do
    # @form_root = true
    nest :research_page, view: :slot_machine
  end

  def menu_item_edit opts
    super opts.merge(path: { RESEARCH_PARAMS_KEY => research_params }, remote: false)
  end

  view :year_edit_link do
    link_to_view :edit_year, menu_icon,
                 path: { RESEARCH_PARAMS_KEY => research_params },
                 class: "_edit-year-link text-dark",
                 "data-slot-selector": ".card-slot.left_research_side-view > div > "\
                                       ".card-slot.TYPE-metric_answer"
  end

  view :edit, wrap: :none do
    handle_research_params
    nest :research_page, view: :edit
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
    # wrap { edit_year_form } #, render_titled(hide: :menu)] }
    edit_year_form
  end

  def answer_delete_button
    confirm = "Are you sure you want to delete the #{card.metric_name} answer "\
              "for #{card.company_name} for #{card.year}?"
    success = research_params.merge(view: :slot_machine, id: Card[:research_page].name)

    smart_link_to "Delete",
                  type: "button",
                  path: { action: :delete, success: success },
                  class: "btn btn-sm btn-outline-danger pull-right",
                  'data-confirm': confirm,
                  "data-disable-with": "Deleting"
  end

  view :edit_buttons do
    class_up "form-group", "w-100 m-3"
    button_formgroup do
      [standard_save_button, cancel_research_button, answer_delete_button]
    end
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

  def edit_year_cancel_button_path
    path research_params.merge mark: :research_page, view: :year_slot
  end

  def edit_year_form
    return not_researchable unless card.metric_card.researchable?

    wrap do
      research_form(:update) do
        haml :edit_year_form,
             slot_attr: "border-bottom p-2 pl-4 d-flex wd-100 justify-content-between "\
                        "flex-nowrap align-items-center"
      end
    end
  end

  def research_form action
    return not_researchable unless card.metric_card.researchable?

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

  def menu_link
    bridge_link + super
  end

  def edit_link view=:edit, _opts={}
    link_to menu_icon, path: research_params.merge(view: view), class: "edit-answer-link"
  end

  # def menu_link_path_opts
  #   super.merge RESEARCH_PARAMS_KEY => research_params
  # end

  def research_params
    @research_params ||=
      inherit(:research_params) ||
      Env.params[RESEARCH_PARAMS_KEY]&.to_unsafe_h ||
      default_research_params
  end

  def default_research_params
    hash = { metric: card.metric, company: card.company, year: card.year }
    hash[:project] = project if project.present?
    hash
  end

  def research_form_success
    research_params.merge id: ":research_page", redirect: true,
                          view: :slot_machine
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
    @project ||= inherit(:project) || Env.params[:project] || Env.params["project"] ||
      research_params[:project]
  end
end
