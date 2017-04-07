# cache # of sources that are tagged with the company (=_ll)
# and the topic (=_lr)
# query for the items that get counted
# (analysis+source+*type_plus_right+*structure):
#  "type":"Source",
#  "right_plus":[["Company", {"refer_to":"_1"}],["Topic",{"refer_to":"_2"}]]
include_set Abstract::SearchCachedCount

def wql_hash
  { type_id: SourceID, right_plus: [[WikirateCompanyID, { refer_to: "_1" }],
                                    [WikirateTopicID, { refer_to: "_2" }]] }
end

def self.notes_for_analyses_applicable_to source
  source.analysis_names.map do |analysis_name|
    Card.fetch analysis_name, :source
  end
end

# recount # of Sources associated with Company+Topic (analysis) when ...

# ...<Source>+company is edited
recount_trigger :type_plus_right, :source, :wikirate_company do |changed_card|
  notes_for_analyses_applicable_to changed_card.left
end

# ...<Source>+topic is edited
recount_trigger :type_plus_right, :source, :wikirate_topic do |changed_card|
  notes_for_analyses_applicable_to changed_card.left
end
