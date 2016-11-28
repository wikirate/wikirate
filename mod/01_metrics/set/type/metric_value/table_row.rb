format :html do


  view :metric_thumbnail_with_vote do
    subformat(card.metric_card)._render_thumbnail_with_vote
  end

  view :company_thumbnail do
    binding.pry
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


  def close_icon
    <<-HTML
      <div class="metric-details-close-icon pull-right	">
        #{fa_icon :circle, class: "fa-2x"}
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
            #{nest "#{card.metric}+discussion", view: :titled, title: "Discussion",
                     show: "commentbox"}
          </div>
      </div>
    HTML
  end

  def metric_details
    wrap_with :div, class: "row clearfix wiki" do
      nest "#{card.metric}+metric details", view: :content
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
      #{close_icon}
      <br>
      <div class="row clearfix">
        <div class="company-logo">
          #{link_to_card card.company_card, nest("#{card.company_card}+image"),
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
    HTML
  end

  # used in metric values list on a company page
  view :metric_details_sidebar do
    <<-HTML
      #{close_icon}
      <br/>
      <div class="row clearfix ">
        #{subformat(metric_card)._render_rich_header}
        <div class="col-md-1">
          #{nest metric_card.field(:vote_count)}
        </div>
        <div class="col-md-11">
          <div class="name row">
            #{link_to_card card.metric_card, nil, class: "inherit-anchor"}
          </div>
          <div class="row">
            <div class="metric-designer-info">
              <a href="/{{_lllr|name}}+contribution">
                <div><small class="text-muted">Designed by</small></div>
                <div>{{_lllr+logo|core;size:small}}</div>
                <div><h3>{{_lllr|name}}</h3></div>
              </a>
            </div>
          </div>
        </div>
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
