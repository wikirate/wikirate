# common filter interface for "Browse Sources" and "Browse Notes" page

include_set Abstract::BrowseFilterForm

class NoteAndSourceFilterQuery < Card::FilterQuery
  def cited_wql value
    case value
    when "yes" then add_to_wql :referred_to_by, cited_true_query[:referred_to_by]
    when "no"  then add_to_wql :not, cited_true_query
    end
  end

  # Has notes?
  def claimed_wql value
    case value
    when "yes" then add_to_wql :referred_to_by, claimed_true_query[:linked_to_by]
    when "no"  then add_to_wql :not, claimed_true_query
    end
  end

  def wikirate_company_wql value
    add_to_wql :right_plus, [{ id: WikirateCompanyID }, { refer_to: value }]
  end

  def wikirate_topic_wql value
    add_to_wql :right_plus, [{ id: WikirateTopicID }, { refer_to: value }]
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

def filter_class
  NoteAndSourceFilterQuery
end

def extra_filter_args
  super.merge limit: 15
end


def add_sort_wql wql, sort_by
  if sort_by == "recent"
    wql[:sort] = "update"
  else
    wql.merge! sort: { right: "*vote count" },
               sort_as: "integer",
               dir: "desc"
  end
end

format :html do
  view :cited_formgroup do |_args|
    select_filter :cited, "Cited", "all"
  end

  view :claimed_formgroup do |_args|
    select_filter :claimed, "Has Notes?", "all",
  end

  view :wikirate_company_formgroup do
    multiselect_filter_type_based :wikirate_company, "Company"
  end

  view :wikirate_topic_formgroup do
    multiselect_filter_type_based :wikirate_topic, "Topic"
  end

  def claimed_options
    { "All" => "all", "Yes" => "yes", "No" => "no" }
  end

  def cited_options
    { "All" => "all", "Yes" => "yes", "No" => "no" }
  end

  def sort_options
    super.merge "Most Important" => "important",
                "Most Recent" => "recent"
  end

  def default_sort_option
    "important"
  end
end
