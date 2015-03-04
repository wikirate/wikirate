def get_query params={}
  filter_words =  Array.wrap(Env.params[:company]) || []
  filter_words += Array.wrap(Env.params[:topic]  ) if Env.params[:topic]
  filter_words += Array.wrap(Env.params[:tag]    ) if Env.params[:tag]
  search_args = { :limit=> 15 }
  search_args.merge!(sort_query)
  search_args.merge!(cited_query)
  search_args.merge!(claimed_query)
  search_args.merge!(:type=>left.name)
  params[:query] = Card.tag_filter_query(filter_words, search_args,['tag','company','topic'])
  super(params)
end


def cited_query
  yes_query = {:referred_to_by=>{:left=>{:type_id=>WikirateAnalysisID},:right_id=>WikirateArticleID}}
  case Env.params[:cited]
  when 'yes' then yes_query
  when 'no'  then {:not=>yes_query}
  else            {}
  end
end

def claimed_query
  yes_query = {:linked_to_by=>{:left=>{:type_id=>ClaimID}, :right_id=>SourceID }}
  case Env.params[:claimed]
  when 'yes' then yes_query
  when 'no'  then {:not=>yes_query}
  else            {}
  end
end


def sort_query
  if Env.params[:sort] == 'important'
    {:sort => {"right"=>"*vote count"}, "sort_as"=>"integer","dir"=>"desc"}
  else
    {:sort => "update" }
  end    
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

  view :filter_form do |args|
    #args[:buttons] = button_tag 'Filter', :class=>'submit-button', :disable_with=>'Filtering'
    content = output([
      optional_render( :sort_fieldset, args),
      optional_render( :claimed_fieldset, args),
      optional_render( :cited_fieldset, args),
      optional_render( :company_fieldset, args),
      optional_render( :topic_fieldset, args),
      optional_render( :tag_fieldset, args),
      #render( :button_fieldset, args )
    ])
    action = card.left.name
    action = 'Source' if action == 'Page'
    %{ <form action="/#{ action }" method="GET">#{content}</form>}
  end
  
  view :sort_fieldset do |args|
    select_filter 'sort',  options_for_select({'Most Recent'=>'recent', 'Most Important'=>'important'}, params[:sort] || 'recent')
  end
  
  view :cited_fieldset do |args|
    select_filter 'cited', options_for_select({'All'=>'all', 'Yes'=>'yes', 'No'=>'no'}, params[:cited] || 'all')
  end
  
  view :claimed_fieldset do |args|
    select_filter 'claimed', options_for_select({'All'=>'all', 'Yes'=>'yes', 'No'=>'no'}, params[:claimed] || 'all')
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
  
  def select_filter type_name, options
    fieldset( type_name.capitalize, select_tag(type_name, options) )
  end
  
  def multiselect_filter type_name, args
    options_card = Card.new :name=>"+#{type_name}"  #codename
    selected_options = params[type_name]
    options = options_from_collection_for_select(options_card.options,:name,:name,selected_options)
    multiselect_tag = select_tag(type_name, options, :multiple=>true, :class=>'pointer-multiselect')
    fieldset( type_name.capitalize, multiselect_tag ,:attribs=>{:class=>"filter-input #{type_name}"} )
  end  
end

