include_set Abstract::MetricChild, generation: 1
include_set Abstract::DeckorateTabbed

card_accessor :answer

event :update_lookups_on_answer_rename, :finalize, changed: :name, on: :update do
  answer_card.search.each(&:refresh)
end

def virtual?
  new?
end

def answers
  answer_card.search
end

private

def expire_left?
  false
end

format do
  delegate :answers, to: :card
end

format :html do
  def tab_list
    %i[answer metric company]
  end

  def tab_options
    tab_list.each_with_object({}) do |tab, hash|
      hash[tab] = { count: nil, label: tab.cardname }
    end
  end

  def header_left
    output [nest(card.metric_card, view: :thumbnail),
            nest(card.company_card, view: :thumbnail)]
  end

  view :answer_tab do
    field_nest :answer, view: :filtered_content
  end

  view :metric_tab do
    nest card.metric_card, view: :details_tab
  end

  view :company_tab do
    nest card.company_card, view: :details_tab
  end
end

format :csv do
  view :body do
    answers.each_with_object("") do |a, res|
      res << CSV.generate_line([a.company, a.year, a.value])
    end
  end
end

format :json do
  def item_cards
    answers
  end
end
