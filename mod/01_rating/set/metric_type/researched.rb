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
      "#{fa_icon :globe} Sources" => path(view: 'source_tab'),
      "#{fa_icon :comment} Discussion" => path(view: 'discussion_tab'),
      'Scores' => path(view: 'scores_tab')
    }
    args[:default_tab] = 'Details'
  end

  view :details_tab do |args|
    tab_wrap do
      [
         _render_add_value_buttons(args),
         nest(card.about_card, view: :titled, title: 'About'),
         nest(card.methodology_card, view: :titled, title: 'Methodology'),
         _render_value_type_detail(args),
         _render_import_button(args)
      ]
    end
  end

  view :value_type_detail do
    <<-HTML
      <div class="row-data titled-view">
        <div class="card-header">Value Type:
          #{_render_value_type_edit_modal_link}
          #{_render_short_view}
        </div>
      </div>
    HTML
  end

  view :source_tab do
    tab_wrap do
      # TODO: get rid of process content
      process_content <<-HTML
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
  end

  view :scores_tab do |args|
    tab_wrap do
      wrap_with :div, class: 'list-group' do
        card.score_cards.map do |item|
          subformat(item)._render_score_thumbnail(args)
        end
      end
    end
  end

  view :content_left_col do |args|
    output [
             _render_year_select(args),
             _render_company_list(args)
           ]
  end

  def add_value_path
    '/new/metric_value?slot[metric]=' + _render_cgi_escape_name
  end

  view :add_value_buttons do |_args|
    <<-HTML
    <div class="col-md-6 padding-top-10">
      <div class="btn-group" role="group" aria-label="...">
      <a class="btn btn-primary"  href='#{add_value_path}'>
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

  view :import_button do |args|
    <<-HTML
      <h5>Bulk Import</h5>
        <div class="btn-group" role="group" aria-label="...">
          <a class="btn btn-default btn-sm" href='/new/source?layout=wikirate%20layout'>
            <span class="fa fa-arrow-circle-o-down"></span>
            Import
          </a>
          <!--
          <a class="btn btn-default btn-sm slotter" href='/?layout=modal' data-toggle='modal' data-target='#modal-main-slot'>
             <small>Help</small>
          </a>
          -->
        </div>
      </div>
    HTML
  end
end
