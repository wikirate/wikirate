include_set Abstract::Filter
include_set Abstract::FilterUtility
def default_sort_by_key
  "upvoted"
end

def shift_sort_table?
  %w(values company).include?(Env.params["sort"] || default_sort_by_key)
end

def default_keys
  %w(name wikirate_topic)
end

def advanced_keys
  %w(designer project year)
end

def target_type_id
  MetricID
end

def sort_by wql, sort_by
  super wql, sort_by
  wql[:sort] =
    case sort_by
    when "values"
      { right: "value", right_plus: "*cached count" }
    when "recent"
      wql.delete :sort_as
      "update"
    when "company"
      { right: "company", right_plus: "*cached count" }
    else
      # upvoted as default
      { right: "*vote count" }
    end
end

def wql_by_wikirate_topic wql, topic
  return unless topic.present?
  wql[:right_plus] ||= []
  wql[:right_plus].push ["topic", { refer_to: topic }]
end

def wql_by_project wql, project
  return unless project.present?
  wql[:referred_to_by] = { left: { name: project }, right: "metric" }
end

def wql_by_year wql, year
  return unless year.present?
  wql[:right_plus] ||= []
  wql[:right_plus].push [
    { type_id: Card::WikirateCompanyID },
    { right_plus: [{ name: year }, {}] }
  ]
end

def wql_by_designer wql, designer
  return unless designer.present?
  wql[:or] = {
    left: designer,
    right: designer
  }
end

format :html do
  def default_sort_formgroup_args args
    args[:sort_options] = {
      "Most Upvoted" => "upvoted",
      "Most Recent" => "recent",
      "Most Companies" => "company",
      "Most Values" => "values"
    }
    args[:sort_option_default] = "upvoted"
  end

  def type_options type_codename, order="asc"
    if type_codename == :wikirate_topic
      Card.search referred_to_by: {
        left: { type_id: Card::MetricID },
        right: "topic"
      }, type_id: Card::WikirateTopicID,
                  return: :name, sort: "name", dir: order
    else
      super type_codename, order
    end
  end
end
