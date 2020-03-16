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

  view :import_template do
    card.companies.map do |company|
      card.metrics.map do |metric|
        import_record_lines metric, company
      end
    end.flatten.join
  end

  def import_record_lines metric, company
    if card.years
      card.years.map { |year| import_answer_line metric, company, year }
    else
      import_answer_line metric, company, ""
    end
  end

  def import_answer_line metric, company, year
    CSV.generate_line [metric, company, year, "", "", ""]
  end
end

format :json do
  # note: if this returned answer objects, it would put answer ids (not card ids) in the
  # json results
  def item_cards
    card.answers.map(&:card)
  end

  def molecule
    super().merge metrics: field_nest(:metric),
                  companies: field_nest(:wikirate_company)
  end
end

format :html do
  view :import_links, cache: :never, template: :haml
end