card_accessor :contribution_count, :type=>:number, :default=>"0"

def indirect_contributor_search_args
  [
    {:left=>{:type=>'metric'}, :right_id=>left.id }
  ]
end