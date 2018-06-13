include Set::Abstract::Calculation

# <OVERRIDES>
def score?
  true
end

def ten_scale?
  true
end

def needs_name?
  false
end

def formula_editor
  categorical? ? :categorical_editor : super
end

def formula_core
  categorical? ? :categorical_core : super
end
# </OVERRIDES>

def scorer
  name.tag
end

def scorer_card
  right
end

def basic_metric
  name.trunk
end

def basic_metric_card
  left
end

def categorical?
  basic_metric_card.categorical?
end

def normalize_value value
  return value if value.is_a? String
  return "0" if value.negative?
  return "10" if value > 10
  value.to_s
end

def value_type
  "Number"
end

def value_options
  basic_metric_card.value_options
end

view :select do
  options = [["-- Select --", ""]] + card.option_names.map { |x| [x, x] }
  select_tag("pointer_select",
             options_for_select(options, card.item_names.first),
             class: "pointer-select  _pointer-select")
end

format :html do
  delegate :scorer_card, :basic_metric_card, to: :card

  def new_name_field _form=nil, _options={}
    option_names = scorable_metrics

    options = [["-- Select --", ""]] + option_names.map { |x| [x, x] }
    new_name_editor_wrap(options, option_names)
  end

  def scorable_metrics
    Card.search type_id: MetricID,
                right_plus: [
                  "*metric type",
                  content: ["in", "[[Formula]]", "[[Researched]]"]
                ], sort: "name", return: :name
  end

  def selected_metric option_names
    if params[:metric] && option_names.include?(params[:metric])
      params[:metric]
    else
      option_names.first
    end
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

  view :scorer_image do
    nest scorer_card.field(:image, new: {}), view: :core, size: :small
  end

  view :score_thumbnail do
    text = "<small class=\"text-muted\">#{time_ago_in_words card.created_at} ago</small>"
    text_with_image title: card.scorer, text: text,
                    size: :icon, image: card.scorer_card.fetch(trait: :image, new: {})
  end

  def properties
    {
      metric_type:   "Metric Type",
      scored_metric: "Scored Metric",
      scorer:        "Scored By",
      topic:         "Topics"
    }
  end

  def scored_metric_property
    nest card.left, view: :thumbnail
  end

  def scorer_property
    nest scorer_card, view: :scorer_info_without_label
  end

  def visit_original_metric_link
    link_to_card basic_metric_card,
                 "#{fa_icon 'external-link'} Original Metric",
                 class: button_classes
  end
end

event :validate_score_name, :validate, changed: :name, on: :save do
  return if basic_metric_card&.type_id == MetricID
  errors.add :name, "#{basic_metric} is not a metric"
end

event :set_scored_metric_name, :initialize,
      on: :create do
  return if name.parts.size >= 3
  metric = (mcard = remove_subfield(:metric)) && mcard.item_names.first
  self.name = "#{metric}+#{Auth.current.name}"
end

event :default_formula, :prepare_to_store,
      on: :create,
      when:  proc { |c| !c.subfield_formula_present?  } do
  add_subfield :formula, content: "{{#{basic_metric}}}",
                         type_id: PlainTextID
end

def subfield_formula_present?
  (f = subfield(:formula)) && f.content.present?
end
