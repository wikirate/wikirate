include_set Abstract::BrowseFilterForm

class SourceFilterQuery < Card::FilterQuery
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
  %w(cited claimed wikirate_company wikirate_topic)
end

def filter_class
  SourceFilterQuery
end

def target_type_id
  SourceID
end

def extra_filter_args
  super.merge limit: 15
end

def sort_by wql, sort_by
  if sort_by == "recent"
    wql[:sort] = "update"
  else
    wql.merge! sort: { "right" => "*vote count" }, sort_as: "integer",
               dir: "desc"
  end
end

format :html do
  def page_link_params
    [:sort, :cited, :claimed, :wikirate_company, :wikirate_topic]
  end

  def sort_options
    super.merge "Most Important" => "important",
                "Most Recent" => "recent"
  end

  def default_sort_option
    "important"
  end
end
