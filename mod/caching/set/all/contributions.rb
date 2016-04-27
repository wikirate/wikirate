def update_direct_contribution_count
  return unless respond_to? :direct_contribution_count
  new_count = intrusive_family_acts.count
  update_contribution_count_card direct_contribution_count_card, new_count
end

def calculate_direct_contribution_count
  if respond_to? :direct_contribution_count
    direct_contribution_count.to_i
  else
    0
  end
end

def indirect_contributor
  indirect_contributor_search_args.inject([]) do |cards, search_args|
    cards + Card.search(search_args)
  end
end

def calculate_indirect_contribution_count

  indirect_contributor.inject(0) do |total, c_card|
    more_contributions =
      case
      when c_card.respond_to?(:contribution_count)
        c_card.contribution_count
      when c_card.respond_to?(:direct_contribution_count)
        c_card.direct_contribution_count
      else
        Card::Act.find_all_with_actions_on(c_card.id).count
      end
    total + more_contributions.to_i
  end
end

def update_contribution_count
  update_direct_contribution_count

  return unless respond_to?(:contribution_count)
  new_count = calculate_direct_contribution_count

  if respond_to? :indirect_contributor_search_args
    new_count += calculate_indirect_contribution_count
  end

  update_contribution_count_card contribution_count_card, new_count
end

def update_contribution_count_card count_card, count
  Card::Auth.as_bot do
    if count_card.new_card?
      count_card.update_attributes! content: count.to_s
    else
      count_card.update_column :db_content, count.to_s
      count_card.expire
    end
  end
end

# find all analysis, source, claim, topic and company cards to which self
# contributes
# FIXME: put into set mods!
def contributees res=[], visited=::Set.new
  return [res, visited] if visited.include? name
  visited << name
  if (type_code == :claim) || (type_code == :source)
    # FIXME: - cardnames
    res += [self]
    res += [Card["#{name}+company"],
            Card["#{name}+topic"]
           ].compact.map(&:known_item_cards).flatten
  elsif type_code == :wikirate_analysis
    res += [self, left, right]
  elsif (type_code == :wikirate_company) || (type_code == :wikirate_topic)
    res << self
  elsif type_code == :metric && (r = right)
    res << r
    Card::Cache[Card::Set::Right::YinyangDragItem].delete key
  elsif type_code == :metric_value
    res << company_card
    Card::Cache[Card::Set::Right::YinyangDragItem].delete metric_card.key
  elsif (l = left) && l.type_code == :metric_value && (r = right) &&
        r.codename == :value.to_s
    res << company_card
    Card::Cache[Card::Set::Right::YinyangDragItem].delete metric_card.key
  else
    if left &&
       !visited.include?(left.name) &&
       ((right_id == VoteCountID) ||
        ((includee_set = Card.search(included_by: left.name).map(&:name)) &&
         !visited.intersection(includee_set).empty?
        )
       )
      res, visited = left.contributees(res, visited)
    end
  end
  [res, visited]
end

def contribution_card?
  (r = right) &&
    (r.codename == 'contribution_count' ||
     r.codename == 'direct_contribution_count'
    )
end

event(:new_contributions, #:integrate,
      :integrate_with_delay,
      when: proc { |c| !c.supercard && c.current_act && !c.contribution_card? }
     ) do
  visited = ::Set.new
  contr = []
  @current_act.actions.each do |action|
    next unless action.card
    contr, visited = action.card.contributees(contr, visited)
  end

  contr.uniq.each do |con_card|
    next unless con_card.respond_to? :update_contribution_count
    con_card.update_contribution_count
  end
end
