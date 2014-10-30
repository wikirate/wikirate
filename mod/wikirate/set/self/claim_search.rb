def get_spec unused={}
  filter_words = Env.params[:filter] ? Env.params[:filter].split(',') : []
  search_args = { :limit=> 10 }
  search_args.merge!( if Env.params[:order] == 'important'
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
  res = Card.claim_tag_filter_spec(filter_words, search_args)
  res.merge(:vars=>{},:context=>(cardname.junction? ? cardname.left_name : cardname))
end


view :filter_form do |args|
  args[:buttons] = button_tag 'Filter', :class=>'submit-button', :disable_with=>'Filtering'

  content = output([
    fieldset('Sort', select_tag("order", options_for_select({'Most Recent'=>'recent', 'Most Important'=>'important'}, params[:order] || 'recent'))),
    fieldset('Cited', select_tag("cited", options_for_select({'All'=>'all', 'Yes'=>'yes', 'No'=>'no'}, params[:cited] || 'all'))),
    fieldset('Company/Topic/Tag', text_field_tag("filter", params[:filter]), :attribs=>{:class=>"filter-input"}),
    render( :button_fieldset, args )
  ])
  %{ <form action="/Claim" method="GET">#{content}</form>}
end
