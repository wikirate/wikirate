
def researched_answers
  Answer.where metric_id: id
end

def answer_ids
  researched_answers.pluck(:id)
end

def random_answer_card
  Answer.search(metric_id: id, limit: 1).first
end

def answer_for company, year
  company = Card.fetch_id(company) unless company.is_a? Integer
  Answer.where(metric_id: id, company_id: company, year: year.to_i).take
end

def answer_name_for company, year
  Card::Name[name, Card.fetch_name(company), year.to_s]
end

# def answer_card company, year
#   field(company)&.field(year.to_s)
# end
#
# def value_cards _opts={}
#   Answer.search metric_id: id, return: :value_card
# end
