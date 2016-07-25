include Card::CachedCount

def related_topic_from_source_or_note
  Card.search(
    type: "Topic",
    referred_to_by: {
      left: {
        type: %w(in Note Source),
        right_plus: ["company", refer_to: cardname.left]
      },
      right: "topic"
    },
    return: "id")
end

def related_topic_from_metric
  Card.search(
    type: "Topic",
    referred_to_by: {
      left: { type: "Metric", right_plus: cardname.left },
      right: "topic"
    },
    return: "id")
end

# get all metric values
def calculate_count _changed_card=nil
  (related_topic_from_source_or_note + related_topic_from_metric).uniq.size
end

# recount topics associated with a company whenever <source>+company is edited
ensure_set { TypePlusRight::Source::WikiRateCompany }
recount_trigger TypePlusRight::Source::WikirateCompany do |changed_card|
  names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
  names.map do |company_name|
    Card.fetch company_name.to_name.trait(:wikirate_topic)
  end
end

# recount topics associated with a company whenever <note>+company is edited
ensure_set { TypePlusRight::Claim::WikiRateCompany }
recount_trigger TypePlusRight::Claim::WikirateCompany do |changed_card|
  names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
  names.map do |company_name|
    Card.fetch company_name.to_name.trait(:wikirate_topic)
  end
end

# FIXME: should also count connections via metrics.
