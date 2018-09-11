include_set Abstract::Media

format :html do
  view :open, cache: :never do
    voo.hide :menu
    super()
  end

  view :edit, cache: :never do
    @answer_view = :research_edit_form
    render_slot_machine
  end

  view :content, cache: :never do
    _render_core
  end

  view :core, cache: :never do
    render_slot_machine
  end

  view :slot_machine, cache: :never, perms: :create do
    slot_machine
  end

  def slot_machine opts={}
    %i[metric company project year active_tab].each do |n|
      instance_variable_set "@#{n}", opts[n] if opts[n]
    end
    wrap do
      haml :slot_machine
    end
  end

  def right_side_tabs
    tabs = {}
    if answer?
      tabs["Source"] = cite_source_tab hide: !cite_mode?
      tabs["View Source"] = view_source_tab hide: hide_view_source_tab?
    end
    tabs["Methodology"] = metric_details_tab if metric?
    tabs['Need Help?'] =
      nest :how_to_research, view: :content
    static_tabs tabs, active_tab, "tabs", pane: { class: "p-3" }
  end

  NEW_BADGE = '<span class="badge badge-danger">New</span>'.freeze

  def cite_mode?
    answer_card.unknown? || @answer_view == :research_edit_form
  end

  def hide_view_source_tab?
    cite_mode? || !existing_answer_with_source?
  end

  def cite_source_tab hide: false
    project # make sure instance variable is set
    hide_tab nest(answer_card, view: :source_tab), hide
  end

  def view_source_tab hide: false
    hide_tab _render_source_preview_tab, hide
  end

  def metric_details_tab
    nest metric, view: :main_details,
                 hide: [:add_value_buttons, :import_button, :about]
  end

  def hide_tab tab, hide=false
    return tab unless hide
    { content: tab, button_attr: { class: "d-none" } }
  end

  view :left_research_side, cache: :never, template: :haml, slot: true do
  end

  view :source_preview_tab, cache: :never do
    wrap do
      nest preview_source, { view: :source_and_preview },
           source_cited: cited_preview_source?,
           source_disabled: existing_answer_with_source?
    end
  end

  view :year_slot, cache: :never do
    haml_partial :year_slot
  end

  # slot means slot machine slot not card slot
  def slot_attr
    "border-bottom p-2 pl-4 d-flex wd-100 justify-content-between flex-nowrap " \
    "align-items-center"
  end

  def project_slot_attr
    "border-bottom px-2 py-2 pl-4 d-flex wd-100 flex-nowrap "
  end

  def answer_slot
    opts = { title: "Answer", hide: [:cited_source_links, :hover_link] }
    opts[:view] = answer_view
    nest answer_card, opts
  end

  def answer_view
    if answer_card.unknown?
      :research_form
    else
      @answer_view || :titled
    end
  end

  def autocomplete_field type, options_card=nil
    codename = type == :company ? :wikirate_company : type
    options_card ||= Card::Name[codename, :type, :by_name]
    text_field_tag codename, "",
                   class: "_research-select #{codename}_autocomplete form-control",
                   "data-options-card": options_card,
                   "data-url": research_url,
                   "data-key": type,
                   "data-slot-selector": ".card-slot.slot_machine-view",
                   "data-remote": true,
                   placeholder: type.to_s.capitalize
  end

  def not_a_metric name
    card.errors.add :Metrics,
                    "Incorrect Metric name or Metric not available: "\
                   "#{name}"
    _render_errors
  end

  view :metric_select do
    wrap do
      metric_select
    end
  end

  def metric_select_tag
    options = metric_list.map.with_index do |metric, i|
      [metric, i]
    end
    select_tag(:metric, options_for_select(options, metric), id: "metric-select", class: "_no-select2") + metric_select_options
  end

  def metric_select
    metric_select_tag
  end

  def metric_select_options
    wrap_with(:div, id:"metric-select-options", class: "d-none") do
      metric_list.map.with_index do |metric, i|
      haml_partial :metric_select_item, metric: metric, company: company, option_id: i
      end
    end
  end
end


format :json do
  view :metric_select_options do
    results =
      metric_list.map.with_index do |metric, i|
        { id: i, text: metric}
      end

    { "results": [
      {
        "id": 1,
        "text": "<h4>Option 1</h4>"

      },
      {
        "id": 2,
        "text": "Option 2",
        "selected": true
      }
    ]
    }
  end
end
