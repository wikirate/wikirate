format :html do
  view :open_content do |args|
    wrap_with :div, class: 'container-fluid yinyang' do
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
        #{ _render_question_row(args) }
		  </div>
	  </div>
    HTML
  end

  view :title_left_col do
    <<-HTML
      <div class="row clearfix ">
        <div class="col-md-1">
          #{field_subformat(:vote_count)._render_content}
        </div>
        <div class="col-md-11">
          <div class="name row">
            #{card_link card.right, class: 'inherit-anchor'}
          </div>
          <div class="row">
            #{_render_designer_info}
          </div>
        </div>
      </div>
    HTML
  end

  view :designer_info do |args|
    wrap_with :div, class: 'metric-designer-info' do
      author_link card.metric_designer_card, 'Designed by'
    end
  end
  def author_link author_card, text
    link_text = <<-HTML
      <div>
        <small class="text-muted">#{text}</small>
      </div>
      <div>
        #{subformat(author_card.field(:image, new:{}))._render_core size: 'small'}
      </div>
      <div><h3>#{author_card.name}</h3></div>
    HTML
    card_link author_card.cardname.field('contribution'),
              text: link_text
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

  view :question_row do |args|
    <<-HTML
      <div class="row question-container">
        <div class="row-icon">
          #{fa_icon 'question'}
        </div>
        <div class="row-data">
          <small>Question</small>
          #{field_subformat('Question')._render_content}
        </div>
      </div>
    HTML
  end

  view :content_row do |args|
    <<-HTML
      <div class="row metric-info">
        <!--Ratings and company list -->
        <div class="col-md-6 rate border-right">
          <div class="row">
            #{field_subformat('right sidebar')._render_content}
          </div>
		    </div>
        <!--Rightside -->
        <div class="col-md-6 wiki">
          #{_render_tabs(args)}
        </div>
	    </div>
    HTML
  end
end
