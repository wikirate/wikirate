format :html do
  view :metric_thumbnail_with_vote do
    subformat(card.metric_card)._render_thumbnail_with_vote
  end

  view :company_thumbnail do
    subformat(card.company_card)._render_thumbnail
  end


  view :company_value do
    if filtered_for_no_values?
      add_value_button
    else
      _render_all_values(args)
    end
  end

  def missing_company_value
    <<-HTML
      <a type="button" target="_blank" class="btn btn-primary btn-sm"
        href="#{add_value_url}">Add answer</a>
    HTML
  end

  def add_value_url
    "/#{card.company.to_name.url_key}?view=new_metric_value&"\
            "metric[]=#{CGI.escape(card.metric_name.to_name.url_key)}"
  end

  def filtered_for_no_values?
    # FIXME: should need to know anything about filter param details here
    params["filter"] && params["filter"]["value"] == "none"
  end

  view :details_placeholder do
    ""
  end
end



