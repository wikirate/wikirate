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
  view :core do
    _render_essentials.merge(answers: answers)
  end

  def answers
    card.answers.map do |answer|
      subformat(answer)._render_core
    end
  end

  def essentials
    {
      metrics: nest(card.metric_card, view: :essentials, hide: :marks),
      companies: nest(card.wikirate_company_card, view: :essentials, hide: :marks)
    }
  end
end
