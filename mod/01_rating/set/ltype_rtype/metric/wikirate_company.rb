def latest_value_year
  cached_count
end

def latest_value_card
  return if !(lvy = latest_value_year) || lvy == 0
  Card.fetch cardname, lvy.to_s
end

def company_card
  right
end

def company_name
  company_card.cardname
end

def company
  cardname.tag
end

def metric_name
  cardname.left
end

def metric
  left
end

format :html do
  def default_menu_args _args
    voo.hide :optional_horizontal_menu
  end

  view :all_values do |args|
    wql = {
      left: card.name,
      type: Card::MetricValueID,
      sort: "name",
      dir: "desc"
    }
    wql_comment = "all metric values where metric = #{card.name}"
    Card.search(wql, wql_comment).map.with_index do |v, i|
      <<-HTML
        <span data-year="#{v.year}" data-value="#{v.value}"
              #{'style="display: none;"' if i > 0}>
          #{subformat(v).render_concise(args)}
        </span>
      HTML
    end.join("\n")
  end

  view :image_link do
    # TODO: change the css so that we don't need the extra logo class here
    #   and we can use a logo_link view on the type/company set
    text = wrap_with :div, class: "logo" do
      card.company_card.format.field_nest :image, view: :core, size: "small"
    end
    link_to_card card.company_card, text, class: "inherit-anchor hidden-xs"
  end

  view :name_link do
    link_to_card card.company_card, nil, class: "inherit-anchor name",
                                         target: "_blank"
  end

  view :metric_row do |args|
    right_box =
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
    wrap do
      process_content <<-HTML
      <div class="drag-item yinyang-row">
        <div class="metric-item value-item">
          <div class="metric-details-toggle"
            data-append="metric_details_metric_header">
            <div class="header">
              <div class="">{{_l+*vote count}}</div>
              <a href="{{_1+contributions|linkname}}">
              <div class="logo hidden-xs hidden-md">
                {{_1+image|core;size:small}}
              </div>
              </a>
              <div class="name">
                <a class="inherit-anchor" href="{{_l|linkname}}"
                  target="_blank">
                  #{card.metric.metric_title}
                </a>
              </div>
            </div>
            <div class="data">
            #{right_box}
            </div>
          </div>
          <div class="details"></div>
        </div>
      </div>
      HTML
    end
  end

  view :yinyang_row do |args|
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
    wrap do
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
end
