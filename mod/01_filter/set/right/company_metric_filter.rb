format :html do
  include Set::Abstract::Filter::HtmlFormat
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

  def company_filter_fields args
    [
      _optional_render(:name_formgroup, args),
      _optional_render(:topic_formgroup, args),
      _optional_render(:project_formgroup, args)
    ]
  end

  def answer_filter_fields args
    [_optional_render(:year_formgroup, args)]
  end

  def default_name_formgroup_args args
    args[:name] = "company"
  end
end
