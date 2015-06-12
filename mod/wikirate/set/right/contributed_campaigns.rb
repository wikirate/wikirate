format :html do
  include ContributedAnalysis::HtmlFormat

  def default_header_args args
    args[:count] = subformat(Card.fetch("#{card.cardname.left}+campaigns edited by+*count"))._render_core
    args[:icon] = '<i class="fa fa-bullhorn"></i>'
  end

end