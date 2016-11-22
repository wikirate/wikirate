format :html do
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

  def load_path item
    metric_plus_company = item.cardname.left_name
    "#{metric_plus_company.right_name.key}+#{metric_plus_company.left_name.key}+yinyang_drag_item"
  end

  def process_cell item, view, td_opts, index
    content = subformat(item)._render(view)
    if td_opts && (td_classes = td_opts[:classes])
      { content: content, class: td_classes[index] }
    else
      content
    end
  end

  def normalize_opts opts
    opts[:tr] ||= {}
    if opts[:details_append]
      add_class opts[:tr], "tr-details-toggle"
      opts[:tr].deep_merge! data: { append: opts.delete(:details_append) }
    end
  end
end
