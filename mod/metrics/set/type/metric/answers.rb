def researched_answers
  Answer.where metric_id: id
end

def answer_ids
  researched_answers.pluck(:id)
end

def random_answer_card
  Answer.search(metric_id: id, limit: 1).first
end

def metric_answer_name company, year
  Card::Name[name, Card.fetch_name(company), year.to_s]
end

