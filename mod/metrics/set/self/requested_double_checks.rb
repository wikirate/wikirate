include_set Abstract::WqlSearch

def wql_hash
  @wql_hash ||= begin
    answer_ids =
      Answer.where("check_requester <> '' AND checkers IS NULL").pluck(:answer_id)
    { type_id: MetricValueID, id: answer_ids.unshift("in") }
  end
end

format do
  view :core do
    view :core, cache: :never do
      _render! :card_list
    end
  end
end
