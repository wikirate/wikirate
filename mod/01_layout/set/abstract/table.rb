
format :html do
  # @param table_type [Symbol] metric, company or topic.
  #   added as html class to the table tag
  # @param [Array] headers header labels
  # @param [Array<Card>] item_cards one card for every row
  # @param [Array<Symbol>] cell_views a view for every column that gets rendered
  #   for every item card
  # @param [Hash] opts add additional classes and other attributes to your table
  # @option opts [Hash] :td options for the td tags. You can pass an array to
  #   :classes to assign to every column a html class.
  # @option opts [Hash] :tr
  def wikirate_table table_type, headers, item_cards, cell_views, opts={}
    normalize_opts opts
    content =
        item_cards.map do |item|
          opts[:tr].deep_merge(
              content: (
              cell_views.map.with_index do |view, i|
                process_cell item, view, opts[:td], i
              end
              ),
              data: { load_path: load_path(item) }
          )
        end
    table_opts = {
        header: headers, class: "wikirate-table #{table_type}"
    }
    table content, table_opts
  end

  # See #wikirate_table.
  # Only differences:
  #   - adds td classes "header", "data", and "details"
  #   - adds :details_placeholder to cell_views
  def wikirate_table_with_details table_type, headers, item_cards, cell_views, opts={}
    cell_views << :details_placeholder
    opts.deep_merge! td: { classes: ["header", "data", "details"] }
  end

  def count_with_label_cell count, label
    output [
               wrap_with(:div, count, class: "count"),
               wrap_with(:div, label, class: "label"),
           ]
  end

  def load_path item
    metric_plus_company = item.cardname.left_name
    "#{metric_plus_company.right_name.key}+#{metric_plus_company.left_name.key}+yinyang_drag_item"
  end

  def process_cell item, view, td_opts, index
    content = subformat(item)._render(view)
    td_classes = (td_opts && td_opts[:classes]) || %(header data details)
    { content: content, class: td_classes[index] }
  end

  def normalize_opts opts
    opts[:tr] ||= {}
    if opts[:details_append]
      add_class opts[:tr], "tr-details-toggle"
      opts[:tr].deep_merge! data: { append: opts.delete(:details_append) }
    end
  end
end
