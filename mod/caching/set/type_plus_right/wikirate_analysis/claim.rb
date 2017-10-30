include_set Abstract::SearchCachedCount

def wql_hash
  { type_id: ClaimID,
    right_plus: [[WikirateCompanyID, { refer_to: name.parts[0] }],
                 [WikirateTopicID, { refer_to: name.parts[1] }]] }
end

def self.notes_for_analyses_applicable_to note
  note.analysis_names.map do |analysis_name|
    Card.fetch analysis_name.to_name.trait(:claim)
  end
end

# recount # of notes associated with Company+Topic (analysis) when ...
# ... <note>+company is edited
recount_trigger :type_plus_right, :claim, :wikirate_company do |changed_card|
  notes_for_analyses_applicable_to changed_card.left
end

# ... <note>+topic is edited
recount_trigger :type_plus_right, :claim, :wikirate_topic do |changed_card|
  notes_for_analyses_applicable_to changed_card.left
end
