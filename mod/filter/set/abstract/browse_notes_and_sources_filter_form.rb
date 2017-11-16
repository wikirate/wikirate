# common filter interface for "Browse Sources" and "Browse Notes" page

include_set Abstract::BrowseFilterForm

class NoteAndSourceFilterQuery < Card::FilterQuery
  # TODO: move this to NoteFilterQuery (inherit from this class)
  def cited_wql value
    case value
    when "yes"
      add_to_wql :referred_to_by, cited_true_query[:referred_to_by]
    when "no"
      add_to_wql :not, cited_true_query
    end
  end

  def cited_true_query
    { referred_to_by: { left: { type_id: WikirateAnalysisID },
                        right_id: OverviewID } }
  end

  # Has notes?
  # TODO: move this to SourceFilterQuery (inherit from this class)
  def claimed_wql value
    case value
    when "yes"
      add_to_wql :referred_to_by, claimed_true_query[:linked_to_by]
    when "no"
      add_to_wql :not, claimed_true_query
    end
  end

  def claimed_true_query
    { linked_to_by: { left: { type_id: ClaimID },
                      right_id: SourceID } }
  end

  def wikirate_company_wql value
    add_to_wql :right_plus, [{ id: WikirateCompanyID }, { refer_to: value }]
  end

  def wikirate_topic_wql value
    add_to_wql :right_plus, [{ id: WikirateTopicID }, { refer_to: value }]
  end
end

def filter_class
  NoteAndSourceFilterQuery
end

def extra_filter_args
  super.merge limit: 15
end

def add_sort_wql wql, sort_by
  if sort_by == "recent"
    wql[:sort] = "update"
    wql[:dir] = "desc"
  else
    wql.merge! sort: { right: "*vote count" },
               sort_as: "integer",
               dir: "desc"
  end
end

format :html do
  view :cited_formgroup, cache: :never do |_args|
    select_filter :cited, "Cited", "all"
  end

  view :claimed_formgroup, cache: :never do |_args|
    select_filter :claimed, "Has Notes?", "all"
  end

  view :wikirate_company_formgroup, cache: :never do
    autocomplete_filter :wikirate_company
  end

  view :wikirate_topic_formgroup, cache: :never do
    multiselect_filter_type_based :wikirate_topic
  end

  def claimed_options
    { "All" => "all", "Yes" => "yes", "No" => "no" }
  end

  def cited_options
    { "All" => "all", "Yes" => "yes", "No" => "no" }
  end
end
