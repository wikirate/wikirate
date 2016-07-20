include_set Abstract::Filter

def default_sort_by_key
  "upvoted"
end

def shift_sort_table?
  %w(values company).include?(Env.params["sort"] || default_sort_by_key)
end

def params_keys
  %w(metric_name designer wikirate_topic project year)
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
  def page_link_params
    [:sort, :metric_name, :designer, :wikirate_topic, :project, :year]
  end

  def default_name_formgroup_args args
    args[:name] = "metric_name"
  end

  def default_sort_formgroup_args args
    args[:sort_options] = {
      "Most Upvoted" => "upvoted",
      "Most Recent" => "recent",
      "Most Companies" => "company",
      "Most Values" => "values"
    }
    args[:sort_option_default] = "upvoted"
  end

  def default_filter_form_args args
    args[:formgroups] = [
      :sort_formgroup, :name_formgroup, :designer_formgroup,
      :topic_formgroup, :project_formgroup, :year_formgroup
    ]
  end
end
