
format :html do
  # @param table_type [Symbol] eg. metric, company or topic.
  #   added as html class to the table tag
  # @param [Array<Card>] row_cards one card for every row or a search card
  #                      whose html format reponds to :search_result
  # @param [Array<Symbol>] cell_views one view for every column. Is rendered
  #   for every row card
  # @param [Hash] opts add additional classes and other attributes to your table
  # @option opts [Array<String>] :header an array with a header for every column
  # @option opts [Symbol] :details_view define a view that gets rendered for the
  #   row cards if a row is clicked
  # @option opts [Hash] :td html options for the td tags. You can pass an array
  #   to :classes to assign to every column a html class.
  # @option opts [Hash] :tr html options for tr tags
  # @option opts [Hash] :table html options for table tags
  def wikirate_table table_type, row_cards, cell_views, opts={}
    @table_context = self
    row_cards, format = normalize_args row_cards
    rendered_table = WikirateTable.new(self, table_type, row_cards,
                                       cell_views, opts).render
    format ? format.with_paging { rendered_table } : rendered_table
  end

  # see #wikirdate_table
  # differences:
  #   - adds td classes "header", "data", and "details"
  #   - adds :details_placeholder to cell_views
  def wikirate_table_with_details table_type, item_cards, cell_views, opts={}
    cell_views << :details_placeholder
    add_td_classes opts, %w[header data details]
    wikirate_table table_type, item_cards, cell_views, opts
  end

  def homepage_table table_type
    wikirate_table(
      table_type,  search_with_params(limit: 4),
      ["#{table_type}_thumbnail_minimal", :value_cell],
      table: { class: "homepage-table" },
      header: [table_type.to_s.capitalize, "Value"],
      td: { classes: ["header", nil] },
      tr_link: lambda do |item|
        path mark: item.metric_card,
             filter: { wikirate_company: item.company }
      end
    )
  end

  def normalize_args row_cards
    if row_cards.is_a? Card::Format
      [row_cards.search_with_params, row_cards]
    else
      [row_cards, false]
    end
  end

  def add_td_classes opts, new_classes
    opts[:td] ||= {}
    opts[:td][:classes] ||= []
    classes = opts[:td][:classes]
    new_classes.each_with_index do |cl, i|
      classes[i] = css_classes classes[i], cl
    end
  end

  def count_with_label_cell count, label
    output [
      wrap_with(:div, count, class: "count"),
      wrap_with(:div, label, class: "label")
    ]
  end
end
