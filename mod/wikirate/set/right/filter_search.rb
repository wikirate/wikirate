def get_spec params={}
  filter_words = Env.params[:company] || []
  filter_words += Env.params[:topic] if Env.params[:topic]
  filter_words += Env.params[:tag] if Env.params[:tag]
  search_args = { :limit=> 10 }
  search_args.merge!( if Env.params[:sort] == 'important'
      {:sort => {"right"=>"*vote count"}, "sort_as"=>"integer","dir"=>"desc"}
    else
      {:sort => "update" }
    end
  )
  cited = case Env.params[:cited]
  when 'yes'
    {:referred_to_by=>{:left=>{:type_id=>WikirateAnalysisID},:right_id=>WikirateArticleID}}
  when 'no'
    {:not=>{:referred_to_by=>{:left=>{:type_id=>WikirateAnalysisID},:right_id=>WikirateArticleID}}}
  end
  search_args.merge!(cited) if cited
  search_args.merge!(:type=>left.name)
  params[:spec] = Card.tag_filter_spec(filter_words, search_args,['tag','company','topic'])
  super(params)
end


format :html do 
  def page_link text, page
    @paging_path_args[:offset] = page * @paging_limit
    filter_args = {}
    [:sort, :cited, :company, :topic, :tag].each do |key|
      filter_args[key] = params[key] if params[key].present?
    end
    " #{link_to raw(text), path(@paging_path_args.merge(filter_args)), :class=>'card-paging-link slotter', :remote => true} "
  end
  
  view :no_search_results do |args|
    %{ 
      <div class="search-no-results">
        No result
      </div>
    }
  end

  view :filter_form do |args|
    #args[:buttons] = button_tag 'Filter', :class=>'submit-button', :disable_with=>'Filtering'
    content = output([
      optional_render( :sort_fieldset, args),
      optional_render( :cited_fieldset, args),
      optional_render( :company_fieldset, args),
      optional_render( :topic_fieldset, args),
      optional_render( :tag_fieldset, args),
      #render( :button_fieldset, args )
    ])
    %{ <form action="/Claim" method="GET">#{content}</form>}
  end
  
  view :sort_fieldset do |args|
    select_filter 'sort',  options_for_select({'Most Recent'=>'recent', 'Most Important'=>'important'}, params[:order] || 'recent')
  end
  
  view :cited_fieldset do |args|
    select_filter 'cited', options_for_select({'All'=>'all', 'Yes'=>'yes', 'No'=>'no'}, params[:cited] || 'all')
  end
  
  view :company_fieldset do |args|
    multiselect_filter 'company', args
  end

  view :topic_fieldset do |args|
    multiselect_filter 'topic',args
  end
  
  view :tag_fieldset do |args|
    multiselect_filter 'tag', args
  end
  
  def select_filter type, options
    fieldset( type.capitalize, select_tag(type, options, :onchange=>"this.form.submit()") )
  end
  
  def multiselect_filter type, args
    options_card = Card.new :name=>"+#{type}"  #codename
    selected_options = params[type]
    options = options_from_collection_for_select(options_card.options,:name,:name,selected_options)
    multiselect_tag = select_tag(type, options, :multiple=>true, :class=>'pointer-multiselect', :onchange=>"this.form.submit()")
    fieldset( type.capitalize, multiselect_tag ,:attribs=>{:class=>"filter-input #{type}"} )
  end  
end

