format :html do
  def metric_select
    research_select_tag :metric, metric_list, metric
  end

  def year_select
    research_select_tag :year, year_list, year
  end

  def research_select_tag name, items, selected
    select_tag_with_html_options(
      name, items, selected: selected, url: -> (item) { research_url(name => item) }
    ) do |item, option_id, selected_option_id|
      option =
        wrap_with :div, id: option_id do
          haml_partial "#{name}_option", item: item
        end
      selected_option =
        wrap_with :div, id: selected_option_id do
          haml_partial "#{name}_selected_option", item: item
        end

      selected_option + option
    end
  end

  def select_tag_with_html_options name, items, selected:, url:, &block
    selected_index = 0
    options = items.map.with_index do |item, i|
      selected_index = i if item == selected
      [item, i, { "data-url": url.call(item),
                  "data-option-selector": "##{name}-option-#{i}",
                  "data-selected-option-selector": "##{name}-selected-option-#{i}" } ]
    end
    s_tag = select_tag(:metric, options_for_select(options, selected_index),
                       class: "_html-select _no-select2",
                       id: "#{name}-html-select")

    s_tag + html_select_options(name, items, &block)
  end

  def html_select_options name, items
    wrap_with(:div, id: "#{name}-select-options", class: "d-none") do
      items.map.with_index do |item, i|
        yield(item, "#{name}-option-#{i}", "#{name}-selected-option-#{i}")
      end
    end
  end
end