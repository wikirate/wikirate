include Card::CachedCount

def self.notes_for_analyses_applicable_to note
  note.analysis_names.map do |analysis_name|
    Card.fetch analysis_name.to_name.trait(:claim)
  end
end

# recount # of Notes associated with Company+Topic (analysis) when ...

# ... <note>+company is edited
ensure_set { TypePlusRight::Claim::WikirateCompany }
recount_trigger TypePlusRight::Claim::WikirateCompany do |changed_card|
  notes_for_analyses_applicable_to changed_card.left
end

# ... <note>+topic is edited
ensure_set { TypePlusRight::Claim::WikirateTopic }
recount_trigger TypePlusRight::Claim::WikirateTopic do |changed_card|
  notes_for_analyses_applicable_to changed_card.left
end
