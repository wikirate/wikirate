card_accessor :contribution_count, :type=>:number, :default=>"0"
card_accessor :direct_contribution_count, :type=>:number, :default=>"0"

view :missing do |args|
  _render_link args
end

def indirect_contributor_search_args
  [
    {:type=>'claim', :plus=>['company',:link_to=>self.name]},
    {:type=>'source', :plus=>['company',:link_to=>self.name]},
    {:type=>'analysis', :left=>self.name }
  ]
end

format :html do
  def edit_slot args
    # refer to claim.rb
    super args.merge( :core_edit=>true )
  end
end

