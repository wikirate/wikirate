def report_type
  @report_type ||= metric_card.fetch :report_type
end

def suggested_sources
  @potential_sources ||= find_suggested_sources
end

# used in lookup
def source_count
  source_card.item_names.size
end

# used in lookup
def source_url
  return unless (url_card = first_source_card&.wikirate_link_card)
  url_card.content.truncate 1024, omission: ""
end

# used in lookup
def first_source_card
  @first_source_card ||= confirmed_first_source_card
end

def cited_source_ids
  @cited_source_ids ||= ::Set.new source_card.item_cards.map(&:id)
end

def cited? source_card
  return unless source_card
  cited_source_ids.include? source_card.id
end

# would not be necessary if data were sufficiently clean
def confirmed_first_source_card
  source_card.first_card.tap do |s|
    return nil unless s&.type_id == SourceID
  end
end
