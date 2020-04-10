# Specifies the structure of a csv row for an answer import.
class AnswerImportItem < ImportItem
  @columns = { metric: { map: true },
               wikirate_company: { map: true },
               year: { map: true },
               value: {},
               source: { map: true },
               comment: { optional: true } }

  def import_hash
    return {} unless (metric_card = Card[metric])
    r = @row.clone
    r[:company] = r.delete :wikirate_company
    metric_card.create_answer_args r.merge(ok_to_exist: true)
  end

  def map_source val
    result = Card::Set::Self::Source.search val
    result.first.id if result.size == 1
  end
end
