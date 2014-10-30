format :html do
  view :search_form do |args|
    args[:buttons] = button_tag 'Filter', :class=>'submit-button', :disable_with=>'Filtering'
    #frame_and_form( { :action=>:read, :id=>card.id, :view=>:filtered }, args ) 
  
    content = output([
      select_tag("order", options_for_select({'Most Recent'=>'recent', 'Most Important'=>'important'}, params[:order] || 'recent')),
      select_tag("cited", options_for_select({'All'=>'all', 'Yes'=>'yes', 'No'=>'no'}, params[:cited] || 'all')),
      text_field_tag("filter", params[:filter]),
      render( :button_fieldset, args )
    ])
    %{ <form action="/Claim" method="GET">#{content}</form>}
  end
end


view :filtered do |args|
  filter_words = params[:filter] ? params[:filter].split(',') : []
  search_args = { :limit=> 10 }
  search_args.merge!( if params[:order] == 'important'
      {:sort => {"right"=>"*vote count"}, "sort_as"=>"integer","dir"=>"desc"}
    else
      {:sort => "update" }
    end
  )
  cited = case params[:cited]
  when 'yes'
    {:referred_to_by=>{:left=>{:type_id=>WikirateAnalysisID},:right_id=>WikirateArticleID}}
  when 'no'
    {:not=>{:referred_to_by=>{:left=>{:type_id=>WikirateAnalysisID},:right_id=>WikirateArticleID}}}
  end
  search_args.merge!(cited) if cited
  final_search_args = Card.claim_tag_filter_spec(filter_words, search_args)
  res = Card.search final_search_args
  
  wrap(args) do
    [
      render_search_form(args),
      res.map do |card|
        nest card, :structure=>"claim item"
      end.join("\n")
    ]
  end
end