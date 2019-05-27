format :html do
  delegate :scorer_card, :basic_metric_card, to: :card

  view :select do
    options = [["-- Select --", ""]] + card.option_names.map { |x| [x, x] }
    select_tag("pointer_select",
               options_for_select(options, card.item_names.first),
               class: "pointer-select  _pointer-select")
  end

  view :score_thumbnail do
    text = "<small class=\"text-muted\">#{time_ago_in_words card.created_at} ago</small>"
    text_with_image title: card.scorer, text: text,
                    size: :icon, image: card.scorer_card.fetch(trait: :image, new: {})
  end

  view :legend do
    "0-10"
  end

  def table_properties
    {
      metric_type:    "Metric Type",
      scored_metric:  "Scored Metric",
      scorer:         "Scored by",
      wikirate_topic: "Topics"
    }
  end

  def new_name_field _form=nil, _options={}
    option_names = scorable_metrics

    options = [["-- Select --", ""]] + option_names.map { |x| [x, x] }
    new_name_editor_wrap(options, option_names)
  end

  def scorable_metrics
    Card.search type_id: MetricID,
                right_plus: ["*metric type",
                             content: scorable_metric_type_content.unshift("in")],
                sort: "name",
                return: :name
  end

  def selected_metric option_names
    if params[:metric] && option_names.include?(params[:metric])
      params[:metric]
    else
      option_names.first
    end
  end

  def scorable_metric_type_content
    scorable_metric_types.map { |type| "[[#{type}]]" }
  end

  def scorable_metric_types
    %i[formula researched descendant]
  end

  def new_name_editor_wrap options, option_names
    selected = selected_metric option_names
    editor_wrap :card do
      hidden_field_tag("card[subcards][+metric][content]", selected,
                       class: "d0-card-content") +
        select_tag("pointer_select",
                   options_for_select(options, selected),
                   class: "pointer-select _pointer-select") +
        help_text.html_safe
    end
  end

  def help_text
    <<-HTML
    <div class="help-block help-text">
      <p>Metric name = [Scored Metric name]+[Your username]</p>
    </div>
    HTML
  end

  def thumbnail_subtitle_text
    "Score | scored by #{link_to_card card.scorer}"
  end

  def scored_metric_property title
    wrap :div, class: "row scored-metric-property" do
      labeled title, nest(card.left, view: :thumbnail)
    end
  end

  def scorer_property title
    wrap :div, class: "row scorer-property" do
      labeled title, nest(scorer_card, view: :thumbnail)
    end
  end
end
