def score_cards
  # we don't check the metric type
  # we assume that a metric with left is a metric again is always a score
  Card.search type_id: MetricID,
              left_id: id
end

format :html do
  def default_content_formgroup_args args
    super(args)
    args[:edit_fields]['+value type'] = { title: 'Value Type'}
    args[:edit_fields]['+research policy'] = { title: 'Research Policy'}
  end

  def default_tabs_args args
    args[:tabs] = {
      'Details' => path(view: 'details_tab'),
      'Sources' => path(view: 'source_tab'),
      "#{fa_icon :comment} Discussion" => path(view: 'discussion_tab'),
      'Scores' => path(view: 'scores_tab')
    }
    args[:default_tab] = 'Details'
  end

  view :details_tab do
    output [
             nest(card.about_card, view: :titled, title: 'About'),
             nest(card.methodology_card, view: :titled, title: 'Methodology'),
             nest(card.value_type_card, view: :titled, item: :name,
                                        title: 'Value Type')
           ]
  end

  view :source_tab do
    <<-HTML
    <div class="row">
      <div class="row-icon">
        <i class="fa fa-globe"></i>
      </div>
      <div class="row-data">
        {{+source|titled;title:Sources;|content;structure:source_item}}
      </div>
    </div>
    HTML
  end

  view :scores_tab do |args|
    items =
      card.score_cards.map do |s_card|
        subformat(s_card)._render_score_thumbnail(args)
      end
    list_tag items
  end

  view :content_left_col do |args|
    output [
             _render_add_value_buttons(args),
             _render_year_select(args),
             _render_company_list(args)
           ]
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

end