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
      source_tab = nest answer_card, view: :source_tab, project: project
      if answer_card.new_card? || @answer_view == :research_edit_form
        tabs["Source"] = source_tab
        tabs["View Source"] = { content: _render_source_preview_tab,
                                button_attr: { class: "d-none" } }
      else
        tabs["Source"] = { content: source_tab, button_attr: { class: "d-none" } }
        tabs["View Source"] = _render_source_preview_tab
      end
    end
    if metric?
      tabs["Metric details"] = nest metric, view: :details_tab_content,
                                            hide: [:add_value_buttons, :import_button]
    end
    tabs["Help"] = nest :how_to_research, view: :core

    static_tabs tabs, active_tab
  end

  view :left_research_side, cache: :never, template: :haml, slot: true do
  end

  view :source_preview_tab, cache: :never do
    wrap do
      nest preview_source, view: :source_and_preview, cited: cited_preview_source?,
                           disabled: existing_answer?
    end
  end

  # slot means slot machine slot not card slot
  def slot_attr
    "border-bottom p-2 pl-4 d-flex wd-100 justify-content-between flex-nowrap " \
    "align-items-center"
  end

  def answer_slot
    opts = { title: "Answer", hide: :cited_source_links,
             research_params: research_params }
    opts[:view] = answer_view
    nest answer_card, opts
  end

  def answer_view
    if answer_card.new_card?
      :research_form
    else
      @answer_view || :titled
    end
  end

  def next_button type
    list = send("#{type}_list")
    index = list.index send(type)
    return if !index || index == list.size - 1
    link_to "Next", path: research_url(type => list[index + 1]),
                    class: "btn btn-sm btn-outline-secondary"
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
                   placeholder: type.to_s.capitalize
  end

  def not_a_metric name
    card.errors.add :Metrics,
                    "Incorrect Metric name or Metric not available: "\
                   "#{name}"
    _render_errors
  end
end
