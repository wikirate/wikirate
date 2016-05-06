def virtual?
  true
end

format :html do
  def page_link text, page, current=false, options={}
    @paging_path_args[:offset] = page * @paging_limit
    filter_args = {}
    [:sort, :cited, :claimed, :company, :topic, :tag].each do |key|
      filter_args[key] = params[key] if params[key].present?
    end
    options.merge!(:class=>'card-paging-link slotter', :remote => true)
    link_to raw(text), path(@paging_path_args.merge(filter_args)), options
  end

  view :no_search_results do |args|
    %{
      <div class="search-no-results">
        No result
      </div>
    }
  end

  def filter_categories
    %w(company industry project)
  end

  def filter_active?
    Env.params.keys.any? { |key| filter_categories.include? key }
  end

  def default_core_args args
    args[:buttons] = [
        card_link(card.left, path_opts: {view: :content_left_col},
                             text: 'Reset', class: 'slotter btn btn-default',
                             remote: true),
        button_tag('Filter', situation: 'primary', disable_with: 'Filtering')
      ].join

  end

  view :core do |args|
    action = card.left.name
    <<-HTML
    <div class="panel panel-default filter">
      <div class="panel-heading" role="tab" id="headingOne" data-toggle="collapse" href="#collapseFilter" aria-expanded="true" aria-controls="collapseFilter">
        <h4 class="panel-title">
            Filter by
        </h4>
      </div>
      <div id="collapseFilter" class="panel-collapse collapse #{'in' if filter_active?}">

        <form action="/#{action}" method="GET">
          <h4>Company</h4>
          #{company_filter_fields(args).join}
           <hr>
          <h4>Answer</h4>
          #{answer_filter_fields(args).join}
          <hr>
          #{ _optional_render( :button_formgroup, args)}
        </form>

      </div>
    </div>
    HTML
  end

  def company_filter_fields args
    [
      _optional_render( :company_formgroup, args),
      _optional_render( :industry_formgroup, args),
      _optional_render( :project_formgroup, args),

    ]
  end

  def answer_filter_fields args
    [
      _optional_render( :year_formgroup, args),
    ]
  end

  view :year_formgroup do |args|
    options = Card.search type_id: YearID, return: :name, sort: 'name', dir: 'desc'
    options.unshift 'latest'
    select_filter 'year', options_for_select(options, params[:year] || 'all'), oneline: true
  end

  view :company_formgroup do |args|
    #options = Card.search type_id: WikirateCompanyID, return: :name
    #multiselect_filter 'company', options, title: 'name'
    text_filter 'company', title: 'Name', oneline: true
  end

  view :industry_formgroup do |args|
    multiselect_filter 'industry',args
  end

  view :project_formgroup do |args|
    options = Card.search type_id: CampaignID, return: :name, sort: 'name'
    multiselect_filter 'project', options
  end

  def text_filter type_name, args
    formgroup args[:title] || type_name.capitalize,
              text_field_tag(type_name, params[type_name], args), args
  end

  def select_filter type_name, options, args={}
    formgroup type_name.capitalize, select_tag(type_name, options), args
  end

  def multiselect_filter type_name, options=nil, args={}
    options ||=
      begin
        options_card = Card.new :name=>"+#{type_name}"  #codename
        options_card.option_names
      end
    selected_options = params[type_name]
    opts_for_select = options_for_select(options, selected_options)
    multiselect_tag = select_tag(type_name, opts_for_select, :multiple=>true, :class=>'pointer-multiselect filter-input')
    formgroup(args[:title] || type_name.capitalize, multiselect_tag, :class=>"filter-input #{type_name}", oneline: true )
  end
end

