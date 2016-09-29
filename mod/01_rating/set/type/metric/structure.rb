format :html do
  view :open_content do
    layout container: true, fluid: true do
      row 6, 6 do
        column _render_content_left_col, class: "metric-info left-col nopadding"
        column _render_content_right_col, class: "wiki right-col"
      end
    end
  end

  view :metric_title do |_args|
    metric_url = "/" + card.cardname.url_key
    metric_title = card.metric_title_card.cardname
    link = link_to metric_title, path: metric_url, class: "inherit-anchor"
    content_tag(:h3, link, class: "metric-color")
  end

  view :metric_question do
    question = subformat(card.question_card)._render_content
    content_tag(:h4, question, class: "question")
  end

  view :title_and_question do
    wrap_with :div do
      [_render_metric_title, _render_metric_question]
    end
  end

  view :metric_header do
    vote = field_subformat(:vote_count)._render_content
    layout do
      row 1, 11, class: "metric-header-container" do
        column vote, class: "margin-top-20 "
        column render_title_and_question
      end
    end
  end

  view :designer_info do
    wrap_with :div, class: "metric-designer-info" do
      link_to_card card.metric_designer_card.cardname.field("contribution"),
                   author_info(card.metric_designer_card, "Designed by")
    end
  end

  def author_info author_card, text, subtext=nil
    author_content =
      subformat(author_card.field(:image, new: {}))._render_core size: "small"
    <<-HTML
      <div>
        <!-- <small class="text-muted">#{text}</small> -->
      </div>
      <div class="image-box small no-margin">
        <span class="img-helper"></span>
        #{author_content}
      </div>
      #{author_text author_card.name, subtext}
    HTML
  end

  def author_text author, subtext=nil
    subtext &&=
      <<-HTML
          <span>
            <small class="text-muted">
              #{subtext}
            </small>
          </span>
        HTML
    args = subtext ? { class: "margin-6" } : {}
    author_args = subtext ? { class: "nopadding" } : {}
    wrap_with :div, args do
      [
        content_tag(subtext ? "h4" : "h3", author, author_args),
        subtext
      ]
    end
  end

  view :content_left_col do |args|
    wrap do
      [
        _render_metric_header,
        _render_filter(args),
        _render_year_select(args),
        _render_company_list(args)
      ]
    end
  end

  # ratings and company list
  view :content_right_col do |args|
    _render_tabs(args)
  end

  view :filter do |args|
    field_subformat(:metric_company_filter)
      ._render_core args.merge(filter_title: "Filter")
  end

  view :year_select do
    # {{#year select|editor}}
    <<-HTML
      <div class="col-md-12 form-horizontal" style="display:none">
        <div class="form-group">
        <!-- show year once filter is done -->
        </div>
      </div>
    HTML
  end

  view :company_list do |_args|
    wrap_with :div, class: "yinyang-list" do
      field_subformat(:all_metric_values)
        ._render_content(hide: "title",
                         items: { view: :yinyang_row })
    end
  end

  view :metric_row do |args|
    wrap(args) do
      process_content <<-HTML
      <div class="yinyang-row">
        <div class="metric-item contribution-item value-item">
          <div class="metric-details-toggle" data-append="topic_page_metric_details">
            <div class="header">
              {{_+*vote count}}
              <div class="logo">
               <a class="inherit-anchor" href="/{{_1|name}}+contribution"> {{_1+image|core;size:small}} </a>
              </div>
              <div class="name">
               <a class="inherit-anchor" href="/{{_|linkname}}">  {{_2|name}} </a>
              </div>
            </div>

            <div class="data">
              <div class="contribution company-count">
                <div class="content">
                  {{_+company count|core}}
                  <div class="name">Companies</div>
                </div>
              </div>
              <div class="contribution metric-details show-with-details text-center">
                <span class="label label-metric">[[_|Metric Details]]</span>
              </div>
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
