format :html do
  def all_answers
    @result ||=
      Answer.fetch({ record_id: card.id }, sort_by: :year, sort_order: :desc)
  end

  view :research_page, unknown_ok: true do
    voo.hide! :chart
    voo.show! :compact_header
    voo.hide! :add_answer_redirect
    wrap do
      _render_content
    end
  end

  # used in four places:
  # 1) metric page -> company table -> item -> table on right side
  # 2) company page -> metric table -> item -> table on right side
  # 3) metric record page
  # 4) add new value page (new_metric_value view for company)
  view :core, unknown_ok: true do
    wrap_with :div, id: card.cardname.url_key, class: "record-row" do
      [
        _optional_render_metric_info,
        _optional_render_buttons,
        _render_value_table
      ]
    end
  end

  # view :content do
  #   if all_answers.empty? || voo.show?(:source_preview)
  #     #class_up "card-slot", "_append_new_value_form"
  #   end
  #   super()
  # end

  view :buttons do
    voo.show :timeline_header_buttons
    wrap_with :div, class: "timeline-header timeline-row " do
      output [add_answer_button,
              nest(metric_card, view: :compact_buttons)]
    end
  end

  view :metric_info do
    opts = { view: :compact }
    opts[:show] = :compact_header if voo.show?(:compact_header)
    nest metric_card, opts
  end

  view :value_table do
    # get rid of "_append_new_value_form" class
    # otherwise child slot will append the form again
    without_upped_class "card-slot" do |up_class|
      # add answer button is above this view so we need
      # js to show it
      if voo.show?(:add_answer_button) && !up_class
        # class_up "card-slot", "_show_add_new_value_button"
      end
      answer_view =
        voo.show?(:chart) ? :closed_answer : :closed_answer_without_chart
      wrap do
        wikirate_table :plain, all_answers,
                       [:plain_year, answer_view],
                       header: %w(Year Answer),
                       td: { classes: ["text-center"] }
      end
    end
  end

  def default_menu_args args
    args[:optional_horizontal_menu] = :hide
  end

  def header_button text, klasses, data
    shared_data = { collapse: ".metric_value_form_container" }
    wrap_with :a, text, class: css_classes(button_classes, klasses),
              data: shared_data.merge(data)
  end

  def add_answer_button
    binding.pry
    return "" unless metric_card.metric_type_codename == :researched &&
      metric_card.user_can_answer?
    if voo.show? :add_answer_redirect
      link_to_card company_card, "Add answer",
                   class: "btn btn-sm btn-primary margin-12",
                   path: { view: "new_metric_value", metric: [card.metric] }
    else # TODO: ugly
      header_button "Add answer",
                    "_add_new_value btn-primary",
                    url: path(view: :table_form),
                    toggle: "collapse-next",
                    parent: ".timeline-data"
    end
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
