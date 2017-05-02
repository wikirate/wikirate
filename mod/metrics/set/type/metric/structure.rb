include_set Abstract::TwoColumnLayout

format :html do
  def default_open_content_args args
    super
    @container_class = "yinyang" # TODO: check if still needed
    add_class args[:left_class], "metric-info nopadding"
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
    wrap_with :h4, question, class: "question"
  end

  view :designer_info do
    wrap_with :div, class: "metric-designer-info" do
      link_to_card card.metric_designer_card,
                   author_info(card.metric_designer_card)
    end
  end

  view :question_row do
    <<-HTML
      <div class="row metric-details-question">
        <div class="row-icon padding-top-10">
          #{fa_icon 'question', class: 'fa-lg'}
        </div>
        <div class="row-data padding-top-10">
          #{nest card.question_card, view: :core}
        </div>
      </div>
    HTML
  end

  view :browse_item , template: :haml do
    @vote_count = voo.show?(:vote_count) ? field_nest(:vote_count) : ""
  end
  view :homepage_item, template: :haml

  def view_template_path view
    super(view, __FILE__)
  end

  def author_info author_card, subtext=nil
    output [
      author_image(author_card),
      author_text(author_card.name, subtext)
    ]
  end

  def author_image author_card
    wrap_with :div, class: "image-box small no-margin" do
      wrap_with :span, class: "img-helper" do
        subformat(author_card.field(:image, new: {}))._render_core size: "small"
      end
    end
  end

  def author_text author, subtext=nil
    if subtext
      author_text_with_subtext author, subtext
    else
      author_text_without_subtext author
    end
  end

  def author_text_with_subtext author, subtext
    wrap_with :div, class: "margin-6" do
      [
        wrap_with(:h4, author, class: "nopadding"),
        %(<span><small class="text-muted">#{subtext}</small></span>)
      ]
    end
  end

  def author_text_without_subtext author
    wrap_with :div do
      wrap_with :h3, author
    end
  end
end
