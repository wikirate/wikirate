include_set Abstract::Chart

format :json do
  def vega_chart_config _highlight=nil
    @data ||= chart_class.new(self,
                              highlight: card.value,
                              layout: { height: 70, width: 300,
                                        padding: { top: 10, left: 50,
                                                   bottom: 20, right: 30 },
                                        max_ticks: 5 },
                              link: false,
                              axes: :light)
  end

  def chart_metric_id
    card.metric_card.id
  end

  def chart_filter_hash
    super.merge year: card.year.to_i
  end
end

format :html do
  view :open_content do
    voo.hide! :cited_source_links
    subformat(:research_page).slot_machine metric: card.metric, company: card.company,
                                           year: card.year, active_tab: "Source preview"
  end

  view :titled_content do
    voo.hide! :chart # hide it in value_field
    bs do
      layout do
        row 12 do
          column value_field
        end
        row 12 do
          column _render_chart
        end
        row 12 do
          column _render_answer_details
        end
      end
    end
  end

  view :listing do
    _render_titled
  end

  # year, value, unit and flags
  view :concise do
    %(
      #{year_and_value}
      <div class="pull-right">
        #{_render_small_flags}
      </div>
    )
  end

  # year, value, unit and flags
  view :conciser do
    year_and_value + _render_flags
  end

  def year_and_value
    <<-HTML
      #{"<span class=\"metric-year\">#{card.year} = </span>" if voo.show? :year}
      <span class="metric-unit"> #{currency} </span>
      #{_render_metric_details}
      <span class="metric-unit"> #{legend} </span>
    HTML
  end
  # value, unit, and flags
  view :value do
    wrap_with :div, class: "td value" do
      [
        wrap_with(:span, currency, class: "metric-unit"),
        _render_value_link,
        wrap_with(:span, legend, class: "metric-unit"),
        checked_value_flag,
        comment_flag,
        _render_value_details_toggle,
        value_details
      ]
    end
  end

  # styled pretty value
  # FIXME: need better name
  view :metric_details do
    span_args = { class: "metric-value" }
    add_class span_args, grade if card.scored?
    add_class span_args, :small if pretty_value.length > 5
    wrap_with :span, span_args do
      beautify(pretty_value).html_safe
    end
  end

  view :modal_details, cache: :never do |args|
    span_args = { class: "metric-value" }
    add_class span_args, grade if card.scored?
    wrap_with :span, span_args do
      subformat(card)._render_modal_link(
        args.merge(
          link_text: pretty_value,
          link_opts: {
            path: { slot: { show: :menu, optional_horizontal_menu: :hide } },
            title: value, "data-complete-number" => value,
            "data-tooltip" => "true", "data-placement" => "top"
          }
        )
      )
    end
  end

  view :year do
    wrap_with :div, class: "td year" do
      [
        wrap_with(:span, card.name.right),
        wrap_with(:div, "", class: "timeline-dot")
      ]
    end
  end
end
