# Specifies the structure of a import item for an answer import.
class AnswerImportItem < ImportItem
  @columns = { metric: { map: true },
               wikirate_company: { map: true },
               year: { map: true },
               value: {},
               source: { map: true },
               comment: { optional: true } }

  def import_hash
    return {} unless (metric_card = Card[metric])

    metric_card.create_answer_args translate_row_hash_to_create_answer_hash
  end

  def map_source val
    result = Card::Set::Self::Source.search val
    result.first.id if result.size == 1
  end

  def translate_row_hash_to_create_answer_hash
    r = @row.clone
    r[:company] = r.delete :wikirate_company
    r[:year] = r[:year].cardname if r[:year].is_a?(Integer)
    r[:ok_to_exist] = true
    r
  end
end
