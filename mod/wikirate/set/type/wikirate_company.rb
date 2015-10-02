card_accessor :contribution_count, :type=>:number, :default=>"0"
card_accessor :direct_contribution_count, :type=>:number, :default=>"0"

view :missing do |args|
  _render_link args
end

def indirect_contributor_search_args
  [
    {:type_id=>Card::ClaimID, :plus=>['company',:link_to=>self.name]},
    {:type_id=>Card::SourceID, :plus=>['company',:link_to=>self.name]},
    {:type_id=>Card::WikirateAnalysisID, :left=>self.name },
    {:type_id=>Card::MetricValueID, :left=>{:right=>self.name}}
  ]
end

format :html do
  def view_caching?
    true
  end

  view :contribution_link do |args|
    no_of_related_metric = Card.search :type_id=>MetricID, :left=>card.name, :return=>"count"
    if no_of_related_metric > 0
      card_link card.name+"+contribution",{:text=>"Contributions",:class=>"btn btn-default company-contribution-link"}
    else
      ""
    end
  end

end

