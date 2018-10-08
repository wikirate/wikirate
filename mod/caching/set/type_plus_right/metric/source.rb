# cache # of sources on which answers for this metric (=left) are based on
include_set Abstract::SearchCachedCount

def wql_hash
  {
    referred_to_by: {
      right: "source",
      left: {           # answer
        left: {         # record
          left: "_left" # metric
        }
      }
    }
  }
end

# recount no. of sources on metric
recount_trigger :type_plus_right, :metric_answer, :source do |changed_card|
  changed_card.left.metric_card.fetch trait: :source
end
