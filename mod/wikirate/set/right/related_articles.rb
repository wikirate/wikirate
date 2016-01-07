format :html do

  view :core do |args|
    body = ''
    if claim = card.left and claim.type_id == Card::ClaimID and analysis_names = claim.analysis_names and analysis_names.length > 0
      # unnecessary if we do this as type plus right
      cited, uncited = [], []
      testparam = params[:citable]
      analysis_names.each do |analysis_name|
        article = Card["#{analysis_name}+#{ Card[:overview].name }"]
        if article && article.includees.include?( card.left )
          cited << analysis_name
        else
          uncited << analysis_name
        end
      end
      if params[:general_overview] && params[:company]
        body +=
          content_tag :div, class: 'related-articles cited-articles related-overviews cited-overviews' do
            card_link "#{params[:company]}+notes_page",
                      text: 'Cite in General Overview',
                      path_opts: {
                        citable: claim.cardname.url_key,
                        edit_general_overview: true
                      },
                      class: 'cite-button'
          end
      end
      if uncited.any?
        body += %{
          <div class="related-articles uncited-articles related-overviews cited-overviews">
            <h3>Overviews that <em>could</em> cite this Claim</h3>
            #{ list_tag uncited.map { |a| analysis_links a } }
              <h2>#{testparam}</h2>
          </div>
        }
      end
      if cited.any?
        body += %{
          <div class="related-articles cited-articles related-overviews cited-overviews">
            <h3>Overviews that cite this Claim</h3>
            <ul>#{ cited.map { |a| "<li>#{ analysis_links a, :cited=>true }" }.join "\n" }</ul>
            <h2>#{testparam}</h2>
          </div>
        }
      end

    else
      body = %{<h3 class="no-article no-overview">No related Overviews yet.</h3>} + subformat(claim).render_tip
    end
    body
  end


  def analysis_links analysis_name, cited=false

    company_name = %{<span class="company">#{analysis_name.to_name.trunk_name}</span>}
    topic_name   = %{<span class="topic">#{  analysis_name.to_name.tag_name  }</span>}
    simple_link  = %{[[#{analysis_name}|#{company_name}#{topic_name}]]}

    citation_link = cited ? '' : citation_link( analysis_name.to_name )

    process_content %{<div class=\"analysis-link\">#{simple_link} #{citation_link}</div>}
  end


  def citation_link analysis_name
    opts = { :edit_article=>true }
    opts[ :citable ] = card.cardname.trunk_name
    %{ <span class="claim-next-action">[[/#{analysis_name.url_key}?#{opts.to_param} | Cite!]]</span> }
  end

end
