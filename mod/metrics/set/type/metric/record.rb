# views used on record and research pages
# probably possible to merge this with other metric views

format :html do
  view :compact do
    voo.hide :compact_header

    wrap_with :div, class: "metric-info" do
      [
        _optional_render_compact_header,
        _optional_render_compact_question,
        collapsed_sections
      ]
    end
  end

  view :compact_header do
    <<-HTML
      <div class="metric-details-header col-md-12 col-xs-12 padding-top-10">
        <div class="row">
          <div class="row-icon no-icon-bg padding-top-10">
              #{link_to_card card,
                             nest(card.designer_image_card,
                                  view: :content,
                                  size: :small),
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

  def collapsed_sections
    output [
      _optional_render_compact_methodology,
      _optional_render_compact_about,
      _optional_render_compact_example_answers
    ]
  end

  view :compact_question do
    <<-HTML
      <div class="col-md-12 padding-bottom-10">
        #{_render_question_row}
      </div>
    HTML
  end

  view :compact_about do
    <<-HTML
      <div class="col-md-12">
        <div class="about-info collapse">
            <div class="row"><small><strong>About</strong>
              #{nest card.about_card, view: :content}
            </small></div>
        </div>
      </div>
    HTML
  end

  view :compact_example_answers do
    return unless card.field(:example_answers)
    <<-HTML
      <div class="col-md-12">
        <div class="example_answers-info collapse">
            <div class="row"><small><strong>Example Answers</strong>
              #{field_nest :example_answers, view: :content}
            </small></div>
        </div>
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
      toggle_button("Methodolgy", ".methodology-info"),
      toggle_button("About", ".about-info"),
      toggle_example_answers,
      _optional_render_page_link_button
    ]
  end

  def toggle_example_answers
    return unless card.field(:example_answers)
    toggle_button("Example Answers", ".example_answers-info")
  end

  def toggle_button text, target
    wrap_with :a, "View #{text}",
              class: css_classes(button_classes, "_toggle_button_text"),
              data: {
                toggle_text: "Hide #{text}",
                toggle: "collapse-next",
                parent: ".record-row",
                target: target
              }
  end

  view :page_link_button do
    link_to_card card, "#{fa_icon 'external-link'} Metric Page",
                 class: button_classes
  end
end
