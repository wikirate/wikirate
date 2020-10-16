include_set Abstract::CqlSearch

def cql_content
  { type_id: Card::MetricAnswerID, id: answer_ids.unshift("in") }
end

def answer_ids
  ::Answer.where("check_requester <> '' AND checkers IS NULL").pluck(:answer_id)
end

def skip_search?
  answer_ids.empty?
end

format do
  view :core, cache: :never do
    _render! :card_list
  end
end
