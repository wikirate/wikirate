format :html do
  view :core do
    body = ""
    if (claim = card.left) && claim.type_id == Card::ClaimID && (analysis_names = claim.analysis_names) && !analysis_names.empty?
      # unnecessary if we do this as type plus right
      cited = []
      uncited = []
      testparam = params[:citable]
      analysis_names.each do |analysis_name|
        article = Card["#{analysis_name}+#{Card[:overview].name}"]
        if article&.nestees&.include?(card.left)
          cited << analysis_name
        else
          uncited << analysis_name
        end
      end
      if params[:general_overview] && params[:company]
        content_class = "related-articles cited-articles " \
                        "related-overviews cited-overviews"
        body += wrap_with :div, class: content_class  do
          link_to_card "#{params[:company]}+notes_page",
                       "Cite in General Overview",
                       path: { citable: claim.name.url_key,
                               edit_general_overview: true },
                       class: "cite-button"
        end
      end
      if uncited.any?
        body += %(
          <div class="related-articles uncited-articles related-overviews cited-overviews">
            <h4>Overviews that <em>could</em> cite this Claim</h4>
            #{list_tag uncited.map { |a| analysis_links(a).html_safe }}
              <h4>#{testparam}</h4>
          </div>
        )
      end
      if cited.any?
        body += %(
          <div class="related-articles cited-articles related-overviews cited-overviews">
            <h4>Overviews that cite this Claim</h4>
            <ul>#{cited.map { |a| "<li>#{analysis_links a, cited: true}" }.join "\n"}</ul>
            <h4>#{testparam}</h4>
          </div>
        )
      end

    else
      body = %(<h4 class="no-article no-overview">No related Overviews yet.</h4>) + subformat(claim).render_tip
    end
    body
  end

  def analysis_links analysis_name, cited=false
    company_name = %(<span class="company">#{analysis_name.to_name.trunk_name}</span>)
    topic_name   = %(<span class="topic">#{analysis_name.to_name.tag_name}</span>)
    simple_link =
      link_to_card analysis_name, "#{company_name}#{topic_name}"

    citation_link = cited ? "" : citation_link(analysis_name.to_name)

    %(<div class=\"analysis-link\">#{simple_link} #{citation_link}</div>)
  end

  def citation_link analysis_name
    opts = { edit_article: true,
             citable: card.name.trunk_name }
    wrap_with :span, class: "claim-next-action" do
      link_to_card analysis_name, "Cite!", path: opts
    end
  end
end
