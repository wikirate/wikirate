def contribution_count
  @cc ||= Card.fetch("#{cardname.left}+campaigns edited by").count
end

format :html do
  include ContributedAnalysis::HtmlFormat

  def default_header_args args
    super(args)
    args[:icon] = '<i class="fa fa-bullhorn"></i>'
  end

end
