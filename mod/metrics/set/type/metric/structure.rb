include_set Abstract::WikirateTable
include_set Abstract::TwoColumnLayout
include_set Abstract::Chart

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

  view :data do
    wrap do
      bs_layout do
        row do
          _optional_render_filter
        end
        row class: "text-center" do
          _render_chart
        end
        row do
          _render_table
        end
      end
    end
  end


  view :filter do
    field_subformat(:metric_company_filter)._render_core
  end

  view :table do
    company_table
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
    wrap_with :h4, question, class: "question"
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
        wrap_with(subtext ? "h4" : "h3", author, author_args),
        subtext
      ]
    end
  end

  view :metric_row_for_topic do |args|
    metric_row_for_topic args
  end
end
