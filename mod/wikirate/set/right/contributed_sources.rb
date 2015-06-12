format :html do
  include ContributedAnalysis::HtmlFormat


  def contribution_count
    @cc ||= Card.search :type_id=>SourceID, :or=>
                        {:created_by=>card.left.name,
                         :edited_by=>card.left.name,
                         :linked_to_by=>{:left=>card.left.name, :right=>["in", "*upvotes", "*downvotes"]}
                        },
                        :return=>:count
  end

  def default_header_args args
    super(args)
    args[:icon] = '<i class="fa fa-globe"></i>'
  end
end