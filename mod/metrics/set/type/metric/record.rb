# views used on record and research pages
# probably possible to merge this with other metric views

format :html do
  view :compact do
    voo.hide :compact_header
    wrap_with :div, class: "metric-info" do
      [
        _optional_render_compact_header,
        _optional_render_compact_question,
        _optional_render_compact_methodology
      ]
    end
  end

  view :compact_header do
    <<-HTML
      <div class="metric-details-header col-md-12 col-xs-12 padding-top-10">
        <div class="row">
          <div class="row-icon no-icon-bg padding-top-10">
              #{link_to_card card,
                             nest(card.designer_image_card, view: :content, size: :small),
                             class: 'editor-image inherit-anchor'}
          </div>
          <div class="row-data">
            	<h4 class="metric-color">
                 #{link_to_card card, card.metric_title, class: 'inherit-anchor'}
        			</h4>
          </div>
        </div>
      </div>
    HTML
  end

  view :compact_question do
    <<-HTML
      <div class="col-md-12 padding-bottom-10">
        #{_render_question_row}
      </div>
    HTML
  end

  view :compact_methodology do
    <<-HTML
      <div class="col-md-12">
        <div class="methodology-info collapse">
            <div class="row"><small><strong>Methodology </strong>
              #{nest card.methodology_card, view: :content,
                     items: { view: :link }}
            </small></div>
            <div class="row">
              <div class="row-icon">
                <i class="fa fa-tag"></i>
              </div>
              <div class="row-data">
                #{nest card.fetch(trait: :wikirate_topic),
                       view: :content, items: { view: :link }}
              </div>
            </div>
        </div>
      </div>
    HTML
  end

  view :compact_buttons do
    output [
             _optional_render_methodology_button,
             _optional_render_page_link_button
           ]
  end

  view :methodology_button do
    wrap_with :a, "View Methodology",
              class: css_classes(button_classes, "_view_methodology"),
              data: {
                toggle: "collapse-next",
                parent: ".record-row",
                target: ".methodology-info"
              }
  end

  view :page_link_button do
    link_to_card card, "#{fa_icon 'external-link'} Metric Page",
                 class: button_classes
  end
end
