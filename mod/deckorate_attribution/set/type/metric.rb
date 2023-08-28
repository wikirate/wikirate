include_set Abstract::Attributable

def attribution_title
  metric_title
end

def attribution_authors
  [metric_designer].tap do |list|
    list << "Wikirate's community" if community_assessed?
  end
end
