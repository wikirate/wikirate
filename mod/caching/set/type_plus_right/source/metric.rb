# cache # of metrics with answers for that cite this source
include_set Abstract::SearchCachedCount

def wql_hash
  {
    type_id: Card::MetricID,
    right_plus: [
      { type_id: Card::WikirateCompanyID }, # record
      { right_plus: [
        { type_id: Card::YearID }, # answer
        { right_plus: [
          { id: Card::SourceID }, # +source
          { link_to: "_left" }
        ]
      }]
    }]
  }
end

# recount no. of sources on metric
recount_trigger :type_plus_right, :metric_answer, :source do |changed_card|
  changed_card.item_cards.map do |source_card|
    source_card.fetch trait: :metric
  end.compact
end
