include_set Abstract::TwoColumnLayout
# include_set Abstract::Listing
include_set Abstract::BsBadge

format :html do
  def left_column_class
    "#{super} metric-info m-0 p-0"
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

  view :metric_title do
    link = link_to_card card, card.metric_title, class: "inherit-anchor"
    wrap_with :h3, link, class: "metric-color"
  end

  view :metric_question do
    wrap_with :div, question, class: "question blockquote"
  end

  def question
    subformat(card.question_card)._render_content
  end

  view :designer_info do
    nest card.metric_designer_card, view: :designer_info
  end

  view :designer_info_without_label do
    nest card.metric_designer_card, view: :designer_info_without_label
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

  view :box_top, template: :haml do
    @vote_count = voo.show?(:vote_count) ? field_nest(:vote_count) : ""
  end

  view :box_middle, template: :haml do
    @question = question
  end

  def company_count
    field_nest :wikirate_company, view: :count
  end

  def metric_count
    field_nest :all_metric_values, view: :count
  end

  view :box_bottom, template: :haml do
    @company_badge = labeled_badge company_count, "Companies", color: "company"
    @answer_badge = labeled_badge metric_count, "Answers", color: "dark"
  end

  view :browse_item, template: :haml do
    @vote_count = voo.show?(:vote_count) ? field_nest(:vote_count) : ""
  end
  view :homepage_item, template: :haml
  view :homepage_item_sm, template: :haml
end
