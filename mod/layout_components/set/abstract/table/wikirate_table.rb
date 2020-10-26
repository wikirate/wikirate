#! no set module

class WikirateTable
  attr_accessor :format
  delegate :add_class, :subformat, :path, :table, to: :format

  def initialize format, table_type, row_cards, cell_views, opts={}
    @format = format

    initialize_opts opts, table_type
    @row_cards = row_cards
    @cell_views = cell_views
  end

  def initialize_opts opts, table_type
    @table_opts = opts.delete(:table) || {}
    @table_opts[:header] = opts.delete(:header)
    add_class @table_opts, "wikirate-table #{table_type}"
    @tr_opts = opts.delete(:tr) || {}
    @td_opts = opts.delete(:td) || {}
    @td_classes = @td_opts.delete(:classes)
    @opts = opts
  end

  def render
    table table_content, @table_opts
  end

  def table_content
    @row_cards.map do |row_card|
      tr_data row_card
    end
  end

  private

  def tr_data row_card
    tr_opts(row_card).merge content: tr_content(row_card)
  end

  def tr_content row_card
    @cell_views.map.with_index do |view, i|
      td_data row_card, view, i
    end
  end

  def tr_opts row_card
    tr = @tr_opts.clone
    if (tr_method = tr.delete(:method))
      tr.merge format.send(tr_method, row_card)
    else
      tr
    end
  end

  def td_data row_card, view, col_index
    td_opts(col_index).merge content: td_content(row_card, view)
  end

  def td_content row_card, view
    subformat(row_card)._render!(view)
  end

  def td_opts col_index
    td = @td_opts.clone
    add_class td, (@td_classes && @td_classes[col_index])
    td
  end
end
