format :html do
  view :open_content do
    wrap_with :div, class: "container-fluid yinyang" do
      [
        _render_title_row,
        _render_content_row
      ]
    end
  end

  view :title_row do |args|
    <<-HTML
    <div class="row wiki">
      <div class="col-md-12 metric-info">
        <div class="row">
          <br>
          <div class="col-md-4 pull-right nopadding">
            #{_render_title_right_col}
          </div>
          <div class="col-md-8 metric-details-header">
            #{_render_title_left_col}
          </div>
        </div>
        <br>
        #{_render_question_row(args)}
		  </div>
	  </div>
    HTML
  end

  view :title_left_col do
    metric_url = "/" + card.cardname.url_key
    metric_title = card.metric_title_card.cardname
    <<-HTML
      <div class="row clearfix ">
        <div class="col-md-1">
          #{field_subformat(:vote_count)._render_content}
        </div>
        <div class="col-md-11">
          <div class="name row">
            #{link_to metric_title, metric_url, class: 'inherit-anchor'}
          </div>
          <div class="row">
            #{_render_designer_info}
          </div>
        </div>
      </div>
    HTML
  end

  view :designer_info do
    wrap_with :div, class: "metric-designer-info" do
      card_link card.metric_designer_card.cardname.field("contribution"),
                text: author_info(card.metric_designer_card, "Designed by")
    end
  end

  def author_info author_card, text, subtext=nil
    author_content =
      subformat(author_card.field(:image, new: {}))._render_core size: "small"
    <<-HTML
      <div>
        <small class="text-muted">#{text}</small>
      </div>
      <div class="img-container">
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

  view :title_right_col do
    <<-HTML
        <!--stuff on the right -->
  <div class="col-md-12 nopadding">
  <div class="row">
  <div class="col-md-3 nopadding">
  <h5>Metric Type:</h5>
            				</div>
  <div class="col-md-9 nopadding">
    #{field_subformat(:metric_type)._render_content item: :name}
  </div>
                  </div>
  <div class="row">
  <div class="col-md-3 nopadding">
  <h5>Tags:</h5>
            				</div>
  <div class="col-md-9 nopadding">
    #{field_subformat(:wikirate_topic)._render_content item: :link}
  </div>
                  </div>
  </div>
    HTML
  end

  view :question_row do
    <<-HTML
      <div class="row question-container">
        <div class="row-icon">
          #{fa_icon 'question'}
        </div>
        <div class="row-data">
          <small>Question</small>
          #{subformat(card.question_card)._render_content}
        </div>
      </div>
    HTML
  end

  view :content_row do |args|
    <<-HTML
      <div class="row metric-info">
        <div class="col-md-6 rate border-right">
          <div class="row">
            #{_render_content_left_col args}
          </div>
		    </div>
        <div class="col-md-6 wiki">
          #{_render_content_right_col(args)}
        </div>
	    </div>
    HTML
  end

  view :content_left_col do |args|
    wrap do
      [
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
    field_subformat(:metric_value_filter)._render_core args
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
      subformat("#{card.name}+all values")
        ._render_content(hide: "title",
                         items: { view: :yinyang_row })
    end
  end
end
