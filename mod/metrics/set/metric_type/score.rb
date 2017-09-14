include Set::Abstract::Calculation

def scorer
  cardname.tag
end

def scorer_card
  right
end

def basic_metric
  cardname.trunk
end

def basic_metric_card
  left
end

def normalize_value value
  return value if value.is_a? String
  return "0" if value < 0
  return "10" if value > 10
  value.to_s
end

def value_type
  "Number"
end

view :select do |_args|
  options = [["-- Select --", ""]] + card.option_names.map { |x| [x, x] }
  select_tag("pointer_select",
             options_for_select(options, card.item_names.first),
             class: "pointer-select form-control")
end

format :html do
  delegate :scorer_card, :basic_metric_card, to: :card

  def new_name_field form=nil, options={}
    form ||= self.form
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
                       class: "card-content") +
        select_tag("pointer_select",
                   options_for_select(options, selected),
                   class: "pointer-select form-control") +
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

  def default_thumbnail_subtitle_args args
    args[:text] ||= "scored by"
    args[:author] ||= link_to_card card.scorer
  end

  view :scorer_info do
    nest scorer_card, view: :designer_info
  end

  view :scorer_image do |_args|
    nest scorer_card.field(:image, new: {}), view: :core, size: :small
  end

  view :score_thumbnail do |_args|
    # link_text =
    #   subformat(card.scorer_card).author_info "#{time_ago_in_words card.created_at} ago"
    # wrap_with :div, class: "metric-designer-info" do
    #   link_to_card card, link_text, class: "row list-group-item"
    # end
    # link_to_card card, link_text
    text = "<small class=\"text-muted\">#{time_ago_in_words card.created_at} ago</small>"
    text_with_image title: card.scorer, text: text,
                    size: :icon, image: card.scorer_card.fetch(trait: :image, new: {})
  end

  view :metric_properties do
    super() + "<hr />".html_safe + visit_original_metric_link
  end

  def visit_original_metric_link
    link_to_card basic_metric_card,
                 "#{fa_icon 'external-link'} Original Metric",
                 class: button_classes
  end

  view :add_to_formula_item_view do |_args|
    subtext = wrap_with :small, "Scored by " + card.scorer
    add_to_formula_helper subtext
  end
end

event :validate_score_name, :validate, changed: :name, on: :save do
  return if basic_metric_card && basic_metric_card.type_id == MetricID
  errors.add :name, "#{basic_metric} is not a metric"
end

event :set_scored_metric_name, :initialize,
      on: :create do
  return if cardname.parts.size >= 3
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
