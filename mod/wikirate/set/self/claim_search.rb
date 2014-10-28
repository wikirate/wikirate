def get_spec unused={}
  filter_words = Env.params[:filter] ? Env.params[:filter].split(',') : []
  search_args = { :limit=> 10 }
  search_args.merge( if Env.params[:order] == 'important'
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