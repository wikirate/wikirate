include_set Abstract::ReportQueries

def item_search_card
  fetch [:type, :by_name]
end

format do
  before :header do
    voo.variant = :plural
  end
end

format :html do
  before :header do
    title = standard_title.to_name.vary :plural
    title = "#{icon_tag card.codename} #{title}" if wr_icon?
    voo.title = title
  end

  def core_with_listing
    output [field_nest(:description),
            render_add_button,
            items_in_rows]
  end

  def items_in_rows
    nest card.item_search_card, items: { view: :bar }
  end

  private

  def wr_icon?
    return false unless card.codename

    basket[:icons][:wikirate].key? card.codename
  end
end
