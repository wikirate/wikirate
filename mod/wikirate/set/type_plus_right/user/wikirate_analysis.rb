format :html do
  include Campaign::HtmlFormat

  def default_header_args args
    args[:count] = Card.search :type_id=>WikirateAnalysisID,
                    :right_plus=>[ 'article', {:or=>{:created_by=>card.left.name, :edited_by=>card.left.name }}],
                    :return=>:count
    args[:icon] = nest(Card.fetch('venn icon'), :view=>:core, :size=>:icon)
  end
end
