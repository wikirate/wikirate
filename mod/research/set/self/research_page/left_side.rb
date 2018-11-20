format :html do
  view :left_research_side, cache: :never, template: :haml, slot: true do
  end

  view :year_slot, cache: :never do
    year_slot
  end

  def metric_select
    research_select_tag :metric, metric_list, metric
  end

  def year_select
    research_select_tag :year, year_list, year
  end

  def year_slot
    wrap do
      haml_partial :year_slot
    end
  end

  def answer_slot
    opts = { title: "Answer", hide: [:cited_source_links, :hover_link] }
    opts[:hide] << :menu if answer_card.metric_type == :relationship
    opts[:view] = answer_view
    nest answer_card, opts
  end

  # slot means slot machine slot not card slot
  def slot_attr
    "border-bottom p-2 pl-4 d-flex wd-100 justify-content-between flex-nowrap " \
    "align-items-center"
  end

  def project_slot_attr
    "border-bottom px-2 py-2 pl-4 d-flex wd-100 flex-nowrap "
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

  def research_select_tag name, items, selected
    tag = SelectTagWithHtmlOptions.new(name, self,
                                       url: ->(item) { research_url(name => item) })
    tag.render(items, selected: selected)
  end
end
