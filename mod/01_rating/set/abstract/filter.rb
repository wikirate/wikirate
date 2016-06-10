
def params_to_hash params
  params.each_with_object({}) do |param, hash|
    if (val = Env.params[param])
      hash[param.to_sym] = val
    end
  end
end

def industry_metric_name
  "Global Reporting Initiative+Sector Industry"
end

def industry_value_year
  "2015"
end

def company_wql opts, return_param=nil
  wql = { type_id: WikirateCompanyID }
  wql[:return] = return_param if return_param
  filter_by_company_name wql, opts[:company] if opts[:company].present?
  filter_by_industry wql, opts[:industry] if opts[:industry].present?
  filter_by_project wql, opts[:project] if opts[:project].present?
  wql
end

def filter_by_company_name wql, name
  wql[:name] = ["match", name]
end

def filter_by_project wql, project
  wql[:referred_to_by] = { left: { name: project } }
end

def filter_by_industry wql, industry
  filter = left.fetch(trait: :metric_value_filter)
  wql[:left_plus] = [
    filter.industry_metric_name,
    { right_plus: [
      filter.industry_value_year,
      { right_plus: ["value", { eq: industry }] }
    ] }
  ]
end

format :html do
  def page_link_params
    []
  end

  view :no_search_results do |_args|
    %(
      <div class="search-no-results">
        No result
      </div>
    )
  end

  def page_link text, page, _current=false, options={}
    @paging_path_args[:offset] = page * @paging_limit
    filter_args = {}
    page_link_params.each do |key|
      filter_args[key] = params[key] if params[key].present?
    end
    options[:class] = "card-paging-link slotter"
    options[:remote] = true
    link_to raw(text), path(@paging_path_args.merge(filter_args)), options
  end

  def text_filter type_name, args
    formgroup args[:title] || type_name.capitalize,
              text_field_tag(type_name, params[type_name],
                             args.merge(class: "form-control")), args
  end

  def select_filter type_name, options, args={}
    formgroup type_name.capitalize,
              select_tag(type_name, options, class: "form-control"),
              args
  end
end


