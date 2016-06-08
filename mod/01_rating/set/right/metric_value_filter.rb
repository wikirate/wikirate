include_set Abstract::Filter

def virtual?
  true
end

format :html do
  def page_link_params
    [:sort, :cited, :claimed, :company, :topic, :tag]
  end

  def filter_categories
    %w(company industry project)
  end

  def filter_active?
    Env.params.keys.any? { |key| filter_categories.include? key }
  end

  def default_core_args args
    args[:buttons] = [
      card_link(card.left, path_opts: { view: :content_left_col },
                           text: "Reset",
                           class: "slotter btn btn-default margin-8",
                           remote: true),
      button_tag("Filter", situation: "primary", disable_with: "Filtering")
    ].join
  end

  view :core do |args|
    action = card.cardname.left_name.url_key
    <<-HTML
    <div class="panel panel-default filter">
      <div class="panel-heading" role="tab" id="headingOne"  data-toggle="collapse" href="#collapseFilter" aria-expanded="true" aria-controls="collapseFilter">
        <h4 class="panel-title accordion-toggle">
            Filter by
        </h4>
      </div>
      <div id="collapseFilter" class="panel-collapse collapse #{'in' if filter_active?}">

        <form action="/#{action}?view=content_left_col" method="GET" data-remote="true" class="slotter">
          <h4>Company</h4>
          <div class="margin-12"> #{company_filter_fields(args).join} </div>
          <div class="filter-buttons">#{_optional_render :button_formgroup, args}</div>
        </form>

      </div>
    </div>
    HTML
  end

  #  <h4>Answer</h4>
  #  #{answer_filter_fields(args).join}

  def company_filter_fields args
    [
      _optional_render(:company_formgroup, args),
      _optional_render(:industry_formgroup, args),
      _optional_render(:project_formgroup, args)
    ]
  end

  def answer_filter_fields args
    [_optional_render(:year_formgroup, args)]
  end

  view :year_formgroup do |_args|
    options = Card.search(
      type_id: YearID, return: :name, sort: "name", dir: "desc"
    )
    options.unshift "latest"
    filter_options = options_for_select(options, params[:year] || "all")
    select_filter "year", filter_options
  end

  view :company_formgroup do
    text_filter "company", title: "Name"
  end

  view :industry_formgroup do
    industries = Card[card.industry_metric_name].value_options
    options = options_for_select([["--", ""]] + industries,
                                 Env.params[:industry])
    select_filter "industry", options
  end

  view :project_formgroup do
    projects = Card.search type_id: CampaignID, return: :name, sort: "name"
    options = options_for_select([["--", ""]] + projects, Env.params[:project])
    select_filter "project", options
  end

  # def multiselect_filter type_name, options=nil, args={}
  #   options ||=
  #     begin
  #       options_card = Card.new name: "+#{type_name}"  # codename
  #       options_card.option_names
  #     end
  #   selected_options = params[type_name]
  #   opts_for_select = options_for_select(options, selected_options)
  #   multiselect_tag = select_tag(
  #     type_name,
  #     opts_for_select,
  #     multiple: true, class: 'pointer-multiselect filter-input'
  #   )
  #   formgroup(args[:title] || type_name.capitalize,
  #             multiselect_tag,
  #             class: "filter-input #{type_name}")
  # end
end
