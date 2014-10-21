card_accessor :contribution_count, :type=>:number, :default=>"0"

view :missing do |args|
  _render_link args
end

def contributer_search_args
  descendants = ['about']
  [
    {:type=>'claim', :plus=>['company',:link_to=>self.name]},
    {:type=>'page', :plus=>['company',:link_to=>self.name]},
    {:right=>{:name=>(descendants.size > 1 ? ['in'].concat(descendants) : descendants.first)}},
    {:right=>'article', :left=>{:left=>self.name}}
  ]
end

