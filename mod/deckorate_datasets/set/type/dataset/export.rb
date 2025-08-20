include_set Abstract::Export

# called by self/dataset
def num_policies
  count = { designer: 0, community: 0 }
  metric_card.item_cards.each do |metric|
    policy = metric.try :assessment
    tally_policy policy, count if policy
  end
  [count[:designer], count[:community]]
end

def tally_policy policy, count
  policy_type = case policy
                when /^designer/i  then :designer
                when /^community/i then :community
                end
  count[policy_type] += 1 if policy_type
end

format :csv do
  view :titled do
    field_nest :answer, view: :titled
  end

  view :import_template do
    (
      [CSV.generate_line(Card::AnswerImportItem.headers)] +
        card.companies.map do |company|
          card.metrics.map do |metric|
            import_answer_lines metric, company
          end
        end
    ).join
  end

  def import_answer_lines metric, company
    if card.years.present?
      card.years.map { |year| import_answer_line metric, company, year }
    else
      import_answer_line metric, company, ""
    end
  end

  def import_answer_line metric, company, year
    CSV.generate_line [metric, company, year, "", "", "", "", ""]
  end
end

format :json do
  # note: if this returned answer objects, it would put answer ids (not card ids) in the
  # json results
  # def item_cards
  #   card.answer.map(&:card)
  # end

  def molecule
    super().merge answers_url: json_field_link(:answer),
                  metrics_url: json_field_link(:metric),
                  companies_url: json_field_link(:company)
  end

  def json_field_link fieldcode
    link_to_card(card.field(fieldcode), nil, path: { format: :json })
  end
end

format :html do
  view :import_links, cache: :never, template: :haml
end
