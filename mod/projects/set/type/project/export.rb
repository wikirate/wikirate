include_set Abstract::Export

# called by self/project
def num_policies
  count = { designer: 0, community: 0 }
  metric_card.item_cards.each do |metric|
    policy = metric.try :research_policy
    tally_policy policy if policy
  end
  [count[:designer], count[:community]]
end

def tally_policy policy, count
  policy_type = case policy
                when "[[Designer Assessed]]"  then :designer
                when "[[Community Assessed]]" then :community
                end
  count[policy_type] += 1 if policy_type
end

format :csv do
  view :core do
    Answer.csv_title + card.answers.map(&:csv_line).flatten.join
  end
end

format :json do
  def item_cards
    card.answers
  end

  view :molecule do
    super().merge metrics: field_nest(:metric), companies: field_nest(:wikirate_company)
  end
end
