format :html do
  
  view :core do |args|
    if claim = card.left and claim.type_id == Card::ClaimID  # unnecessary if we do this as type plus right
      process_content( claim.analysis_names.map do |analysis_name|
        company_name = %{<span class="company">#{analysis_name.to_name.trunk_name}</span>}
        topic_name   = %{<span class="topic">#{  analysis_name.to_name.tag_name  }</span>}
        %{
          <div class=\"analysis-link\">
            [[#{analysis_name}|#{company_name}#{topic_name}]]
            #{ next_action_link analysis_name}
          </div>
        }
      end.join ' ')
    end
  end
  
  def next_action_link analysis_name
    article = Card["#{analysis_name}+Article"]
    act = case
      when !article;                                'Start a new Article'
      when !article.includees.include?( card.left); 'Cite this Claim'
      else                                          'Review Article'
      end
    %{ <span class="claim-next-action">[[#{analysis_name} | #{ act }]]</span> }
  end
  
end
