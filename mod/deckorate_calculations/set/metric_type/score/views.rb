# format do
#   def value_legend
#     "0-10"
#   end
# end

format :html do
  delegate :scorer_card, :scoree_card, to: :card

  before :new do
    return unless card.name.blank? && (metric_name = card.drop_field(:variables)&.content)

    card.name = Card::Name[metric_name, Auth.current.name]
  end

  view :new do
    return super() if card.new?

    alert(:warning) { "You have already scored this metric: #{link_to_card card}." }
  end

  view :metric_tree_branch do
    [algorithm, scoree_card.format.metric_tree_item]
  end

  view :select do
    options = [["-- Select --", ""]] + card.option_names.map { |x| [x, x] }
    select_tag("pointer_select",
               options_for_select(options, card.first_name),
               class: "pointer-select  _pointer-select")
  end

  # view :scorer_image do
  #   nest scorer_image_card, view: thumbnail_image_view,
  #                           title: card.scorer,
  #                           size: thumbnail_image_size
  # end

  view :thumbnail_subtitle, template: :haml

  def algorithm
    format_algorithm algorithm_content
  end

  def algorithm_content
    field_nest card.formula_field, view: :core
  end

  # def scorer_image_card
  #   scorer_card.fetch :image, new: { type: :image }
  # end

  def table_properties
    {
      scored_metric:  "Scored Metric",
      scorer:         "Scored by",
      topic: "Topics",
      metric_type:    "Metric Type",
      unpublished:    "Unpublished"
    }.merge applicability_properties
  end

  def header_text
    super + metric_type_details
  end

  view :name_formgroup do
    return super() unless card.new?

    formgroup "Scored Metric", input: "name", help: score_name_help_text do
      new_score_name_field
    end
  end

  def new_score_name_field
    option_names = card.scorable_metrics.map(&:name).sort.map { |x| [x, x] }
    options = [["-- Select --", ""]] + option_names
    new_name_editor_wrap options, card.name.left
  end

  def new_name_editor_wrap options, selected
    editor_wrap :card do
      [hidden_field_tag("card[subcards][+metric]", selected, class: "d0-card-content"),
       select_tag("pointer_select", options_for_select(options, selected),
                  class: "pointer-select _pointer-select")]
    end
  end

  def score_name_help_text
    "full metric name = [scored metric]+[your username]"
  end

  def scored_metric_property title
    wrap_with :div, class: "row scored-metric-property" do
      labeled title, nest(card.left, view: :thumbnail)
    end
  end

  def scorer_property title, size=nil
    wrap_with :div, class: "row scorer-property" do
      labeled title, nest(scorer_card, view: :thumbnail, size: size)
    end
  end

  def autocomplete_label
    "#{super}<small>#{metric_type_details}</small>"
  end
end
