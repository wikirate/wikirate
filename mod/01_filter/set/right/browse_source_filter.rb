include_set Abstract::BrowseFilterForm

class SourceFilter < Abstract::FilterQuery::Filter
  def cited_wql
    case value
      when "yes" then @filter_wql[:referred_to_by] << cited_true_query[:referred_to_by]
      when "no"  then @filter_wql[:not] << cited_true_query
    end
  end

  # Has notes?
  def claimed_wql
    case value
      when "yes" then @filter_wql[:referred_to_by] << claimed_true_query[:linked_to_by]
      when "no"  then @filter_wql[:not] << claimed_true_query
    end
  end

  def cited_true_query
    { referred_to_by: { left: { type_id: WikirateAnalysisID },
                        right_id: OverviewID } }
  end

  def claimed_true_query
    { linked_to_by: { left: { type_id: ClaimID },
                      right_id: SourceID } }
  end
end

def filter_keys
  %(cited claimed wikirate_company wikirate_topic)
end

def filter_class
  SourceFilter
end

def target_type_id
  SourceID
end
