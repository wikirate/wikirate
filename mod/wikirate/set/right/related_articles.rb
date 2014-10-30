format :html do
  
  view :core do |args|
    if claim = card.left and claim.type_id == Card::ClaimID and analysis_names = claim.analysis_names
      # unnecessary if we do this as type plus right
      articles = analysis_names.map do |analysis_name|
        company_name = %{<span class="company">#{analysis_name.to_name.trunk_name}</span>}
        topic_name   = %{<span class="topic">#{  analysis_name.to_name.tag_name  }</span>}
        %{
          <div class=\"analysis-link\">
            [[#{analysis_name}|#{company_name}#{topic_name}]]
            #{ next_action_link analysis_name.to_name}
          </div>
        }
      end.join ' '
      articles = "<span class='no-article'>No related Article</span>"+ claim.format.render_tips if analysis_names.length == 0
      process_content( articles )
    end
  end
  
  def next_action_link analysis_name
    article = Card["#{analysis_name}+Article"]
    act = case
      when !article;                                'Cite'
      when !article.includees.include?( card.left); 'Cite'
      else                                          'View'
      end
    if act == "Cite"
      opts = { :edit_article=>true }
      opts[ :citable ] = card.cardname.trunk_name 
    end
    %{ <span class="claim-next-action">[[/#{analysis_name.url_key}?#{opts.to_param} | #{ act }]]</span> }
  end
  
end
