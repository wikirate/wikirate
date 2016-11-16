include_set Abstract::WikirateTable
include_set Abstract::TwoColumnLayout

format :html do
  def default_open_content_args args
    super
    @container_class = "yinyang" # TODO: check if still needed
    add_class args[:left_class], "metric-info"
    add_class args[:right_class], "wiki"
  end

  view :rich_header do
    vote = field_subformat(:vote_count)._render_content
    bs_layout do
      row 1, 11, class: "metric-header-container" do
        column vote, class: "margin-top-20 "
        column _render_title_and_question
      end
    end
  end

  view :filter do |args|
    field_subformat(:metric_company_filter)._render_core
  end

  view :table do |args|
    _render_company_list args
  end

  view :title_and_question do
    wrap_with :div do
      [_render_metric_title, _render_metric_question]
    end
  end

  view :metric_title do |_args|
    link = link_to_card card, card.metric_title, class: "inherit-anchor"
    content_tag :h3, link, class: "metric-color"
  end

  view :metric_question do
    question = subformat(card.question_card)._render_content
    content_tag :h4, question, class: "question"
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

  view :company_list do |_args|
    # renders yinyang_row view of ltype_rtype/metric/company
    yinyang_list field: :all_metric_values, row_view: :company_row_for_metric
  end

  view :metric_row_for_topic do |args|
    metric_row_for_topic args
  end
end
