def report_type
  @report_type ||= metric_card.fetch :report_type
end

# used in lookup
def source_count
  source_card.item_names.size
end

def source_required?
  standard? || hybrid?
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

# would not be necessary if data were sufficiently clean
def confirmed_first_source_card
  s = source_card.first_card
  s if s&.type_id == SourceID
end
