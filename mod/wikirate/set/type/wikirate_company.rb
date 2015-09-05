card_accessor :contribution_count, :type=>:number, :default=>"0"
card_accessor :direct_contribution_count, :type=>:number, :default=>"0"

view :missing do |args|
  _render_link args
end

def indirect_contributor_search_args
  [
    {:type_id=>ClaimID, :plus=>['company',:link_to=>self.name]},
    {:type=>'source', :plus=>['company',:link_to=>self.name]},
    {:type=>'analysis', :left=>self.name },
    {:type=>'metric value', :left=>{:right=>self.name}}
  ]
end

format :html do
  def view_caching?
    true
  end
end

