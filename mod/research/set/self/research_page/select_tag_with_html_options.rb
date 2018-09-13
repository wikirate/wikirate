#! no set module

# Option tags in a select tag can't have html.
# This class provides a way around this restriction.
# The options are invisible outside of the select_tag. select2 + js
# make them visible inside of the select tag.
#
#
class SelectTagWithHtmlOptions
  def initialize name, format,
                 url:,
                 option_template: "#{name}_option",
                 selected_option_template: "#{name}_selected_option"
    @name = name
    @url = url
    @format = format
    @option_template = option_template
    @selected_option_template = selected_option_template
  end

  def render items, selected: nil
    @items = items
    @selected = selected

    select_tag + html_options
  end

  def select_tag
    @format.select_tag(@name, text_options, class: "_html-select _no-select2",
                                            id: "#{@name}-html-select")
  end

  def option_id i
    "#{@name}-option-#{i}"
  end

  def selected_option_id i
    "#{@name}-selected-option-#{i}"
  end

  def text_options
    selected_index = 0
    options = @items.map.with_index do |item, i|
      selected_index = i if item == @selected
      [item, i, { "data-url": @url.call(item),
                  "data-option-selector": "##{@name}-option-#{i}",
                  "data-selected-option-selector": "##{@name}-selected-option-#{i}" }]
    end
    @format.options_for_select(options, selected_index)
  end

  def html_options
    @format.wrap_with(:div, id: "#{@name}-select-options", class: "d-none") do
      @items.map.with_index do |item, i|
        html_option(item, i) + selected_html_option(item, i)
      end
    end
  end

  def html_option item, i
    @format.wrap_with :div, id: option_id(i) do
      @format.haml_partial @option_template, item: item
    end
  end

  def selected_html_option item, i
    @format.wrap_with :div, id: selected_option_id(i) do
      @format.haml_partial @selected_option_template, item: item
    end
  end
end