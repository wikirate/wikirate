def update_direct_contribution_count
  return unless direct_contribution_count_card
 
  new_contr_count = intrusive_family_acts.count
  Card::Auth.as_bot do
    direct_contribution_count_card.update_attributes!(:content => new_contr_count.to_s)
  end
end

def update_contribution_count
  update_direct_contribution_count
  return unless respond_to?(:contribution_count_card)
  new_contr_count = direct_contribution_count.to_i
  if respond_to? :indirect_contributer_search_args
    indirect_contributer = indirect_contributer_search_args.inject([]) do |cards, search_args|
      cards += Card.search(search_args)
    end
    new_contr_count += indirect_contributer.inject(0) do |res,c_card| 
      res += if c_card.respond_to?(:contribution_count)
        c_card.contribution_count.to_i
      elsif c_card.respond_to?(:direct_contribution_count)
        c_card.direct_contribution_count.to_i
      else
         Card::Act.find_all_with_actions_on(c_card.id).count
      end
    end
    #new_contr_count += Card::Act.find_all_with_actions_on(indirect_contributer_ids).count
  end
  Card::Auth.as_bot do
    contribution_count_card.update_attributes!(:content => new_contr_count.to_s)
  end
end


# find all analysis, source, claim, topic and company cards to which self contributes
def contributees res=[], visited=::Set.new
  visited << self.name
  if type_code == :claim or type_code == :webpage
    res += [self] + [Card["#{name}+company"], Card["#{name}+topic"]].compact.map do |pointer|
	      pointer.item_cards
	    end.flatten
  elsif type_code == :wikirate_analysis
    res += [self, left, right]  
  elsif type_code == :wikirate_company or type_code == :wikirate_topic
    res << self
  else
    if left and !visited.include?(left.name) and
      ( 
        right_id == VoteCountID or
        ( includee_set = Card.search(:included_by=>left.name).map(&:name) and
         !visited.intersection(includee_set).empty? )
      )
      res, visited = left.contributees(res, visited)
    end
  end
  [res, visited]
end

event :new_contributions, :before=>:extend, :when=>proc{ |c| !c.supercard and c.current_act} do
  visited = ::Set.new
  contr = []
  @current_act.actions.each do
    contr, visited = contributees( contr, visited )
  end
  contr.uniq.each do |con_card|
    con_card.update_contribution_count if con_card.respond_to? :update_contribution_count
  end
end