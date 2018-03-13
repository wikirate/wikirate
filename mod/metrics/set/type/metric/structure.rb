include_set Abstract::TwoColumnLayout
include_set Abstract::Listing

format :html do
  def left_column_class
    "#{super} metric-info nopadding"
  end

  def right_column_class
    "#{super} wiki"
  end

  view :rich_header do
    vote = field_subformat(:vote_count)._render_content
    bs_layout do
      row 1, 11, class: "metric-header-container border-bottom container p-0 m-0 mt-3" do
        column vote, class: "col-1 pt-1"
        column _render_title_and_question, class: "col-10"
      end
    end
  end

  view :data, cache: :never do
    field_nest :all_metric_values
  end

  view :title_and_question do
    wrap_with :div do
      [_render_metric_title, _render_metric_question]
    end
  end

  view :metric_title do |_args|
    link = link_to_card card, card.metric_title, class: "inherit-anchor"
    wrap_with :h3, link, class: "metric-color"
  end

  view :metric_question do
    question = subformat(card.question_card)._render_content
    wrap_with :div, question, class: "question blockquote"
  end

  view :designer_info do
    nest card.metric_designer_card, view: :designer_info
  end

  view :question_row do
    <<-HTML
      <div class="row metric-details-question">
        <div class="row-icon">
          #{fa_icon 'question', class: 'fa-lg'}
        </div>
        <div class="row-data col-11">
          #{nest card.question_card, view: :core}
        </div>
      </div>
    HTML
  end

  view :box_header, template: :haml do
    @vote_count = voo.show?(:vote_count) ? field_nest(:vote_count) : ""
  end

  view :box_top do
    _render_box_header
  end

  view :box_middle do
    "haa chi haa chi haa chi hoo"
  end
  view :box_bottom do
    "footer"
  end
  view :browse_item, template: :haml do
    @vote_count = voo.show?(:vote_count) ? field_nest(:vote_count) : ""
  end
  view :homepage_item, template: :haml
  view :homepage_item_sm, template: :haml
end
