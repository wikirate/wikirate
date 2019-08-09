format :html do
  view :left_research_side, cache: :never, template: :haml, wrap: :slot
  view :project_slot,       cache: :never, template: :haml
  view :metric_slot,        cache: :never, template: :haml
  view :company_slot,       cache: :never, template: :haml
  view :year_slot,          cache: :never, template: :haml, wrap: :slot

  def answer_slot
    opts = { view: answer_view,
             title: "Answer",
             hide: :hover_link }
    opts[:hide] << :menu if answer_card.metric_type == :relationship
    nest answer_card, opts
  end

  def answer_view
    if answer_card.unknown?
      :research_form
    else
      @answer_view || :titled
    end
  end

  # option view is on record
  def metric_select
    research_select_tag :metric, metric_list, metric, ->(m) { record_for_metric m }
  end

  def record_for_metric metric
    Card.fetch [metric, company], new: { type_id: Card::RecordID }
  end

  # option view is on answer
  def year_select
    research_select_tag :year, year_list.unshift(nil), year, ->(y) { answer_for_year y }
  end

  def answer_for_year year
    Card.fetch [metric, company, year], new: { type_id: Card::MetricAnswerID }
  end

  def research_select_tag name, items, selected, option_get
    tag = SelectTagWithHtmlOptions.new(name, self,
                                       url: ->(item) { research_url(name => item) },
                                       option_get: option_get)
    tag.render(items, selected: selected)
  end

  # slot means slot machine slot not card slot
  def slot_attr
    "border-bottom p-2 pl-4 d-flex wd-100 justify-content-between flex-nowrap " \
    "align-items-center"
  end

  def project_slot_attr
    "border-bottom px-2 py-2 pl-4 d-flex wd-100 flex-nowrap "
  end

  def first_missing_field
    %i[metric company year].find { |field| !(send "#{field}?") }
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
    card.errors.add :Metrics, "Incorrect Metric name or Metric not available: #{name}"
    _render_errors
  end
end
