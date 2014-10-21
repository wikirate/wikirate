def update_contribution_count
  contributer_ids = contributer_search_args.inject([]) do |ids, search_args|
    ids += Card.search(search_args.merge(:return=>'id'))
  end
  new_contr = Card::Act.where( "id IN (?)",
    Card::Action.where("card_id IN (?)", contributer_ids).pluck("card_act_id")
  )
  new_contr_count = Card::Act.where( "id IN (?)",
    Card::Action.where("card_id IN (?)", contributer_ids).pluck("card_act_id")
  ).count
  if contribution_count_card
    Card::Auth.as_bot do
      contribution_count_card.update_attributes!(:content => new_contr_count.to_s)
    end
  end
end

def contributees
  res = if type_code == :claim or type_code == :webpage
    [Card["#{name}+company"], Card["#{name}+topic"]].compact.map do |pointer|
      pointer.item_cards
    end.flatten
  elsif left
    if [:wikirate_company, :wikirate_topic].include? left.type_code and right.key == 'about'
      [left]
    elsif left.type_code == :wikirate_analysis and right.key == 'article'
      [left.right, left.left]
    end
  end
  res ||= []
end

event :contributions, :after=>:extend, :on=>:save do
  contributees.each do |con_card|
    con_card.update_contribution_count
  end
end