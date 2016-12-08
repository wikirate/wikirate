include_set Abstract::Media

format :html do
  view :metric_thumbnail_with_vote do
    subformat(card.metric_card)._render_thumbnail_with_vote
  end

  view :company_thumbnail do
    company_image = card.company_card.fetch(trait: :image)
    title = card.company_card.name
    text_with_image title: title, image: company_image, size: :icon
  end

  view :value_cell do
    if filtered_for_no_values?
      add_value_button
    else
      _render_concise
    end
  end

  def add_value_url
    "/#{card.company.to_name.url_key}?view=new_metric_value&"\
            "metric[]=#{CGI.escape(card.metric_name.to_name.url_key)}"
  end

  def add_value_button
    <<-HTML
        <a type="button" target="_blank" class="btn btn-primary btn-sm"
          href="#{add_value_url}">Add answer</a>
    HTML
  end

  def filtered_for_no_values?
    return card.new_card?
    # FIXME: wrong place.
    # should not need to know anything about filter param details here
    params["filter"] && params["filter"]["value"] == "none"
  end

  view :details_placeholder do
    ""
  end


  def close_icon
    <<-HTML
      <div class="details-close-icon pull-right	">
        #{fa_icon "times-circle", class: "fa-2x"}
      </div>
    HTML
  end

  def discussion
    <<-HTML
      <div class="row discussion-container">
      <div class="row-icon">
        #{fa_icon :comment}
      </div>
      <div class="row-data">
            #{nest "#{card.metric_record}+discussion", view: :titled, title: "Discussion",
                   show: "commentbox" }
          </div>
      </div>
    HTML
  end

  def metric_details
    wrap_with :div, class: "row clearfix wiki" do
      nest "#{card.metric_record}+metric details", view: :content
    end
  end

  def metric_values
    wrap_with :div, class: "row clearfix wiki" do
      nest "#{card.metric_record}+metric values", view: :timeline
    end
  end

  # used in metric value list on a metric page
  view :company_details_sidebar do
    <<-HTML
    <div class="metric-details-company-header">
      #{close_icon}
      <br>
      <div class="row clearfix">
        <div class="company-logo">
          #{link_to_card card.company_card,
                         nest(card.company_card.fetch(trait: :image)),
                         class: "inherit-anchor"}
        </div>
        <div class="company-name">
          #{link_to_card card.company_card, nil, class: "inherit-anchor"}
        </div>
      </div>
      <hr>
      #{metric_details}
    #{metric_values}
      <br>
      #{discussion}
    </div>
    HTML
  end

  def metric_details_sidebar_header
    bs do
      layout do
        row 1, 11 do
          column nest(card.metric_card.vote_count_card)
          column do
            row link_to_card(card.metric_card, card.metric_card.cardname.right,
                             class: "inherit-anchor"),
                class: "name"
            row designer_info
          end
        end
      end
    end
  end

  def designer_info
    <<-HTML
      <div class="metric-designer-info">
        <a href="/{{_lllr|name}}+contribution">
          <div><small class="text-muted">Designed by</small></div>
          <div>#{nest card.metric_card, view: :designer_info}</div>
        </a>
      </div>
    HTML
  end

  #lllr+logo|core;size:small}}

  # used in metric values list on a company page
  view :metric_details_sidebar do
    <<-HTML
    <div class="metric-details-header">
      #{close_icon}
      <div class="row clearfix padding-top-20">
        #{metric_details_sidebar_header}
      </div>
      <hr>
      #{metric_details}
    #{metric_values}
      <br>
      <div class="row clearfix">
        <div class="data-item text-center">
          <span class="btn label-metric">
            #{link_to_card card.metric_card, "Metric Details"}
          </span>
        </div>
      </div>
      <hr>
      #{discussion}
    </div>
    HTML
  end
end
