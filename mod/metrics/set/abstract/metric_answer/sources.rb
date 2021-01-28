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
  @first_source_card ||= source_card.first_card
end

def find_suggested_sources
  return [] unless report_type&.item_ids&.any? && Card::Auth.current_id
  Card.search type_id: Card::SourceID,
              right_plus: [[Card::WikirateCompanyID, { refer_to: company }],
                           [Card::ReportTypeID,
                            { link_to: { linked_to_by: report_type.id } }]],
              # TODO: optimize the above sql so that we can use report_type.item_ids
              not: { creator_id: Card::Auth.current_id }
end

def my_sources
  return [] unless Card::Auth.current_id
  @my_sources ||=
    Card.search type_id: Card::SourceID,
                right_plus: [Card::WikirateCompanyID, { refer_to: company }],
                creator_id: Card::Auth.current_id,
                sort: :create, dir: :desc
end

def cited_source_ids
  @cited_source_ids ||= ::Set.new source_card.item_cards.map(&:id)
end

def cited? source_card
  return unless source_card
  cited_source_ids.include? source_card.id
end
