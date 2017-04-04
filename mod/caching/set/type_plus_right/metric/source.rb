# cache # of sources on which values for metric (=_left) are based on
include_set Abstract::CachedCount
include_set Type::SearchType

def virtual?
  true
end

def wql_hash
  { referred_to_by: {
    right: "source",
    left: {                 # answer
      left: {               # record
              left: "_left" # metric
      }
    }
  } }
end

# recount no. of sources on metric
ensure_set { TypePlusRight::MetricValue::Source }
recount_trigger MetricValue::Source do |changed_card|
  changed_card.left.metric_card.fetch trait: :source
end
