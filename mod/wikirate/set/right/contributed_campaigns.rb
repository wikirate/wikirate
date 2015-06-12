format :html do
  include ContributedAnalysis::HtmlFormat

  def contribution_count
    @cc ||= subformat(Card.fetch("#{card.cardname.left}+campaigns edited by+*count"))._render_core
  end

  def default_header_args args
    super(args)
    args[:icon] = '<i class="fa fa-bullhorn"></i>'
  end

end