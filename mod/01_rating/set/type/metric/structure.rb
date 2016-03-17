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
    output [
      _render_add_value_buttons(args),
      _render_year_select(args),
      _render_company_list(args)
    ]
  end

  # ratings and company list
  view :content_right_col do |args|
    _render_tabs(args)
  end

  def add_value_path
    '/new/metric_value?layout=modal&slot[metric]=' +
      _render_cgi_escape_name
  end

  view :add_value_buttons do |_args|
    <<-HTML
    <div class="col-md-12 text-center">
      <div class="btn-group" role="group" aria-label="...">
      <a class="btn btn-default slotter"  href='#{add_value_path}'
         data-toggle='modal' data-target='#modal-main-slot'>
        #{fa_icon 'plus'}
        Add new value
      </a>
      <a class="btn btn-default" href='/new/source?layout=wikirate%20layout'>
        #{fa_icon 'arrow-circle-o-down'}
        Import
      </a>
      <a class="btn btn-default slotter"
         href='/import_metric_values?layout=modal'
         data-toggle='modal' data-target='#modal-main-slot'>
        Help <small>(how to)</small>
      </a>
      </div>
    </div>
    HTML
  end

  view :year_select do |args|
    # {{#year select|editor}}
    <<-HTML
      <div class="col-md-12 form-horizontal" style="display:none">
        <div class="form-group">
        <!-- show year once filter is done -->
        </div>
      </div>
    HTML
  end

  view :company_list do |args|
    wrap_with :div, class: 'yinyang-list' do
      subformat("#{card.name}+all values")
        ._render_core(hide: 'title',
                         items: { view: 'content',
                            slot: { structure: 'metric company  item' }})
    end
  end
end
