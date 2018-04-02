include_set Abstract::MetricChild, generation: 1

def all_answers
  @result ||=
    Answer.search(record_id: id, sort_by: :year, sort_order: :desc)
end

format :html do
  delegate :all_answers, to: :card

  # used in four places:
  # 1) metric page -> company table -> item -> table on right side
  # 2) company page -> metric table -> item -> table on right side
  # 3) metric record page
  # 4) add new value page (new_metric_value view for company)
  view :core, unknown_ok: true do
    wrap_with :div, id: card.name.url_key, class: "record-row" do
      [
        _render_metric_info,
        _render_buttons,
        _render_answer_table
      ]
    end
  end

  view :buttons do
    wrap_with :div, class: "margin-12" do
      [
        add_answer_button,
        more_buttons
      ]
    end
  end

  def more_buttons
    return "" unless voo.show? :metric_buttons
    nest metric_card, view: :compact_buttons
  end

  view :metric_info do
    opts = { view: :compact }
    opts[:show] = :compact_header if voo.show?(:compact_header)
    nest metric_card, opts
  end

  # calculated answers don't show up if we cache this
  view :answer_table, cache: :never do
    if voo.hide?(:answer_form) && voo.show?(:answer_redirect_button)
      class_up "card-slot", "_show_add_new_value_button"
    end
    answer_view = voo.show?(:chart) ? :closed_answer : :closed_answer_without_chart
    wrap do
      next "" unless all_answers.present?
      wikirate_table(:plain, all_answers,
                     [:plain_year, answer_view],
                     header: %w[Year Answer],
                     td: { classes: ["text-center"] })
    end
  end

  def add_answer_button
    return "" unless metric_card.user_can_answer?
    link_to_card :research_page, "Research answer",
                 class: "btn btn-sm btn-primary margin-12",
                 path: { view: "slot_machine", metric: card.metric, company: card.company },
                 title: "Research answer for another year"
  end

  def default_menu_args _args
    voo.hide :horizontal_menu
  end

  view :image_link do
    # TODO: change the css so that we don't need the extra logo class here
    #   and we can use a logo_link view on the type/company set
    text = wrap_with :div, class: "logo" do
      card.company_card.format.field_nest :image, view: :core, size: "small"
    end
    link_to_card card.company_card, text, class: "inherit-anchor hidden-xs"
  end

  view :name_link do
    link_to_card card.company_card, nil, class: "inherit-anchor name",
                                         target: "_blank"
  end
end

format :csv do
  view :core do
    res = ""
    all_answers.each do |a|
      res += CSV.generate_line [a.company, a.year, a.value]
    end
    res
  end
end
