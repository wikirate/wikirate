include_set Abstract::MetricChild, generation: 1

def all_answers
  @result ||=
    Answer.search(record_id: id, sort_by: :year, sort_order: :desc)
end

format :html do
  delegate :all_answers, to: :card

  view :research_page, unknown_ok: true do
    voo.hide! :chart
    voo.show! :compact_header
    voo.hide! :add_answer_redirect
    frame do
      [
        _render_answer_side,
        nest(:research_page, view: :source_side)
      ]
    end
  end

  view :answer_side do
    wrap_with :div, class: "panel-default nodblclick stick-left" do
      _render_content
    end
  end

  # used in four places:
  # 1) metric page -> company table -> item -> table on right side
  # 2) company page -> metric table -> item -> table on right side
  # 3) metric record page
  # 4) add new value page (new_metric_value view for company)
  view :core, unknown_ok: true do
    voo.hide :answer_form
    voo.show :add_answer_redirect
    wrap_with :div, id: card.name.url_key, class: "record-row" do
      [
        _render_metric_info,
        _render_buttons,
        # _render_new_answer
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

  view :answer_table do
    if voo.hide?(:answer_form) && voo.show?(:answer_redirect_button)
      class_up "card-slot", "_show_add_new_value_button"
    end
    answer_view = voo.show?(:chart) ? :closed_answer : :closed_answer_without_chart
    wrap do
      next "" unless all_answers.present?
      output [_render_answer_form,
              wikirate_table(:plain, all_answers,
                             [:plain_year, answer_view],
                             header: %w[Year Answer],
                             td: { classes: ["text-center"] })]
    end
  end

  view :new_answer_success do
    voo.hide! :chart
    voo.hide! :answer_form
    _render_answer_table
  end

  def add_answer_button
    return "" unless metric_card.researched? && metric_card.user_can_answer?
    if voo.show?(:add_answer_redirect) && voo.hide?(:answer_form)
      redirect_form_button
    else
      show_form_button
    end
  end

  def default_menu_args args
    args[:optional_horizontal_menu] = :hide
  end

  def show_form_button
    classes = "_add_new_value btn-primary"
    classes << " hide" if voo.show?(:answer_form)
    wrap_with :a, "Research Answer",
              href: "#",
              class: css_classes(button_classes, classes),
              data: { url: path(view: :answer_form) },
              title: "Research answer for another year"
  end

  def redirect_form_button
    link_to_card card, "Research answer",
                 class: "btn btn-sm btn-primary margin-12",
                 path: { view: "research_page", slot: { show: :answer_form } },
                 title: "Research answer for another year"
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
