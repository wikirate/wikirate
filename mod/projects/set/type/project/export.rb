def num_policies
  d_cnt = 0
  c_cnt = 0
  metric_card.item_cards.each do |mc|
    next unless (policy = mc.try(:research_policy))
    case policy
      when "[[Designer Assessed]]" then d_cnt += 1
      when "[[Community Assessed]]" then c_cnt += 1
    end
  end
  [c_cnt, d_cnt]
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