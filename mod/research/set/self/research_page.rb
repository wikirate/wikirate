include_set Abstract::Media

format :html do
  view :open do
    voo.hide :menu
    super()
  end

  view :content do
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

  view :source_tab do
    wrap do
      haml :source_tab
    end
  end

  view :source_preview_tab do
    wrap do
      nest preview_source, view: :source_and_preview
    end
  end

  def new_source_form
    params[:company] = company
    nest Card.new(type_id: Card::SourceID), view: :new_research
  end

  def answer_slot
    view = answer_card.new_card? ? :research_form : :titled
    wrap do
      nest answer_card, view: view, title: "Answer"
    end
  end

  def right_side_tabs
    tabs = {}
    if answer?
      tabs["Source"] = _render_source_tab
      tabs["View Source"] = { content: _render_source_preview_tab,
                              button_attr: { class: "d-none" } }
    end
    tabs["Metric details"] = nest metric, view: :details_tab_content,
                                          hide: [:add_value_buttons, :import_button]
    tabs["Help"] = nest :how_to_research, view: :core

    static_tabs tabs, active_tab
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
                   placeholder: type.to_s.capitalize
  end

  def not_a_metric name
    card.errors.add :Metrics,
                    "Incorrect Metric name or Metric not available: "\
                   "#{name}"
    _render_errors
  end
end
