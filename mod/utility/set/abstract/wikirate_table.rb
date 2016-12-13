format :html do


  def metric_row header, data, args={}
    row_class = "yinyang-row"
    row_class = "drag-item #{row_class}" if args[:drag_and_drop]
    item_class = args[:item_types].map do |t|
      "#{t}-item"
    end.join " "
    inner = wrap_with(:div, header, class: "header") +
            wrap_with(:div, data, class: "data")

    if args[:append_for_details]
      inner = wrap_with :div, class: "metric-details-toggle",
                          "data-append" => args[:append_for_details] do
                inner
              end
    end

    content = wrap_with :div, class: row_class do
      wrap_with(:div, inner, class: item_class) +
        wrap_with(:div, "", class: "details")
    end
    process_content content
  end

  def item_wrap args

  end

  def wikirate_list

  end

  def company_row_for_topic args
    topic = parent.card.cardname.left
    header = <<-HMTL
               <div class="logo">
                 {{_+image|core;size:small}}
               </div>
               <a class="name" href="{{_|linkname}}">{{_|name}}</a>
    HMTL
    wrap(args) do
      metric_row header, "{{_1+#{topic}+analysis contributions|core}}",
                 item_types: [:company, :contribution]
    end
  end

  def metric_row_for_topic args
    header = <<-HTML
      {{_+*vote count}}
      <div class="logo">
      <a class="inherit-anchor" href="/{{_1|name}}+contribution"> {{_1+image|core;size:small}} </a>
              </div>
      <div class="name">
        {{_2|name}}
      </div>
    HTML
    data = <<-HTML
    <div class="contribution company-count">
                <div class="content">
                  {{_+company count|core}}
                  <div class="name">Companies</div>
                </div>
              </div>
              <div class="contribution metric-details show-with-details text-center">
                <span class="label label-metric">[[_|Metric Details]]</span>
              </div>
    HTML
    wrap(args) do
      metric_row header, data, drag_and_drop: false,
                 item_types: [:metric, :contribution, :value],
                 append_for_details: "topic_page_metric_details"
    end
  end

  def metric_row_for_company args
    header = <<-HTML
      <div class="">{{_l+*vote count}}</div>
      <a href="{{_1+contributions|linkname}}">
      <div class="logo hidden-xs hidden-md">
        {{_1+image|core;size:small}}
      </div>
      </a>
      <div class="name">
        #{card.metric.metric_title}
      </div>
    HTML

    data =
      if Env.params["value"] == "none"
        url = "/#{card.company.to_name.url_key}?view=new_metric_value&"\
          "metric[]=#{CGI.escape(card.metric_name.to_name.url_key)}"
        <<-HTML
        <a type="button" target="_blank" class="btn btn-primary btn-sm add-answer"
          href="#{url}">Add answer</a>
        HTML
      else
        <<-HTML
          <div class="data-item hide-with-details">
            {{_+latest value|concise}}
          </div>
          <div class="data-item show-with-details text-center">
            <span class="label label-metric">[[_l|Metric Details]]
            </span>
          </div>
        HTML
      end
    wrap(args) do
      metric_row header, data, drag_and_drop: true,
                 item_types: [:metric, :value],
                 append_for_details: "metric_details_metric_header"
    end
  end

  def company_row_for_metric args
    right_box =
      if Env.params["value"] == "none"
        url = "/#{card.company.to_name.url_key}?view=new_metric_value&"\
          "metric[]=#{CGI.escape(card.metric_name.to_name.url_key)}"
        <<-HTML
        <a type="button" target="_blank" class="btn btn-primary btn-sm"
          href="#{url}">Add answer</a>
        HTML
      else
        <<-HTML
          <div class="data-item">
            #{_render_all_values(args)}
          </div>
        HTML
      end
    append_name =
      if card.left.metric_type_codename == :score
        "score_metric_details_company_header"
      else
        "metric_details_company_header"
      end
    wrap(args) do
      <<-HTML
      <div class="yinyang-row">
        <div class="company-item value-item">
          <div class="metric-details-toggle"
               data-append="#{append_name}">
            <div class="header">
              #{_render_image_link}
      #{_render_name_link}
            </div>
            <div class="data">
              #{right_box}
            </div>
        </div>
        <div class="details">
        </div>
        </div>

      </div>
      HTML
    end
  end

  def yinyang_list args
    wrap_with :div, class: "yinyang-list" do
      field_subformat(args[:field])
        ._render_content(hide: "title",
                         items: { view: args[:row_view]})
    end
  end
end
