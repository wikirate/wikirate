include_set Abstract::Filter

def params_keys
  %w(company_name industry project)
end

def default_sort_by_key
  "metric"
end

format :html do
  def page_link_params
    [:sort, :company_name, :industry, :project]
  end

  def default_filter_form_args args
    args[:formgroups] = [
      :sort_formgroup, :name_formgroup, :industry_formgroup, :project_formgroup
    ]
  end

  def default_name_formgroup_args args
    args[:name] = "company_name"
  end

  def default_sort_formgroup_args args
    args[:sort_options] = {
      "Most Metrics" => "metric", "Most Topics" => "topic"
    }
    args[:sort_option_default] = "metric"
  end
end
