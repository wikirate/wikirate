
format :html do
  # @param table_type [Symbol] eg. metric, company or topic.
  #   added as html class to the table tag
  # @param [Array<Card>] row_cards one card for every row or a search card
  #                      whose html format reponds to :search_result
  # @param [Array<Symbol>] cell_views one view for every column. Is rendered
  #   for every row card
  # @param [Hash] opts add additional classes and other attributes to your table
  # @option opts [Array<String>] :header an array with a header for every column
  # @option opts [Hash] :td html options for the td tags. You can pass an array
  #   to :classes to assign to every column a html class.
  # @option opts [Hash] :tr html options for tr tags
  # @option opts [Hash] :table html options for table tags
  def wikirate_table table_type, row_cards, cell_views, opts={}
    @table_context = self
    row_cards, format = normalize_table_args row_cards
    rendered_table = WikirateTable.new(self, table_type, row_cards,
                                       cell_views, opts).render
    format ? format.with_paging { rendered_table } : rendered_table
  end

  def normalize_table_args row_cards
    if row_cards.is_a? Card::Format
      [row_cards.search_with_params, row_cards]
    else
      [row_cards, false]
    end
  end
end
