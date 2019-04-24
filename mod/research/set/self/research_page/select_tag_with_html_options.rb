#! no set module

# Option tags in a select tag can't have html.
# This class provides a way around this restriction.
# The options are rendered invisible outside of the select tag.
# Javascript (triggered by "_html-select" class) makes them visible inside the select
# field.
#
# Example
#  fruits = SelectTagWithHtmlOptions.new(:fruit, url: ->(item) { "/#{item}" })
#  fruits.render(["apple", "orange"])
#  =>
#    <select name="fruit" id="fruit-html-select" class="_html-select _no-select">
#       <option value="0"
#               data-url="/apple"
#               data-option-selector="#fruit-option-0"
#               data-selected-option-selector="#fruit-selected-option-0">
#         Apple
#       </option>
#       <option value="1" ...>
#         Orange
#       </option>
#    </select>
#    <div id="fruit-select-options" class="d-none">
#       <div id="fruit-option-0">
#         [the rendered option_view; default: "fruit_option"]
#      </div>
#       <div id="fruit-selected-option-0">
#         [the rendered selected_option_view; default "fruit_selected_option"]
#       </div>
#    </div>
class SelectTagWithHtmlOptions
  # @param name [Symbol] a unique identifier for the select tag. Must be a valid css id.
  # @param format [Card::Format] format needed to render html tags
  # @param url [Block] block must return for every option item a url to be loaded when
  #                    the option is selected.
  # @param option_view [Symbol, Block] view shown for each option
  # @param selected_option_view [Symbol, Block] view shown when option is selected
  def initialize name, format,
                 url:,
                 option_view: "#{name}_option",
                 selected_option_view: "#{name}_selected_option",
                 option_card:
    @name = name
    @url = url
    @format = format
    @option_view = option_view
    @selected_option_view = selected_option_view
    @option_card = option_card
  end

  # Accepts an array of items and returns a string with select tag and additional div tags
  # with options that are bound via JavaScript as options to the select tag
  # @param items [Array] options for the select tag. Each item is passed to the option and
  #                      selected_option template/proc and to the url proc.
  # @param selected must be equal to one of the `items` to make that item preselected
  def render items, selected: nil
    @items = items
    @selected = selected

    select_tag + html_options
  end

  def select_tag
    @format.select_tag(@name, text_options, class: "_html-select _no-select2",
                                            id: "#{@format.unique_id}-html-select")
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
                  "data-option-selector": "##{option_id(i)}",
                  "data-selected-option-selector": "##{selected_option_id(i)}" }]
    end
    @format.options_for_select(options, selected_index)
  end

  def html_options
    @format.wrap_with(:div, id: "#{@name}-select-options", class: "d-none") do
      @items.map.with_index do |option, i|
        option_card = @option_card ? @option_card.call(option) : Card[option]
        html_option(option_card, i) + selected_html_option(option_card, i)
      end
    end
  end

  def html_option option_card, i
    @format.wrap_with :div, id: option_id(i) do
      call_or_render option_card, @option_view
    end
  end

  def selected_html_option option_card, i
    @format.wrap_with :div, id: selected_option_id(i) do
      call_or_render option_card, @selected_option_view
    end
  end

  def call_or_render option_card, view
    if option_card.respond_to?(:call)
      # "view" here is really a proc. only used in test. obviate?
      option_card.call view
    else
      @format.nest option_card, view: view
    end
  end
end
