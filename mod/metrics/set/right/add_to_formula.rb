include_set Abstract::HamlFile
include_set Abstract::Table
include_set Abstract::BrowseFilterForm

def filter_keys
  %i[name wikirate_topic wikirate_company]
end

def advanced_filter_keys
  %i[designer project metric_type research_policy year]
end

def target_type_id
  MetricID
end

def filter_class
  MetricFilterQuery
end

def sort_hash
  {}
end

def default_sort_option
  "name"
end

def default_filter_option
  { name: "" }
end

def virtual?
  true
end

def metric_card
  left
end

def metric_card_name
  name.left_name
end

def split_metrics
  metric_parts = name.parts.size - 1
  (metric_parts - 1).downto(1) do |split|
    next unless (l = self[0..split]) && l.type_id == MetricID &&
                (r = self[split + 1..metric_parts - 1]) && r.type_id == MetricID
    return l, r
  end
end

def sort?
  false
end

format :html do
  view :metric_type_formgroup, cache: :never do
    metric_type_select
  end

  view :research_policy_formgroup, cache: :never do
    research_policy_select
  end

  view :wikirate_topic_formgroup, cache: :never do
    autocomplete_filter :wikirate_topic
  end

  def filter_label field
    case field.to_sym
    when :name then "Name"
    when :metric_type then "Metric type"
    else super
    end
  end

  def haml_locals
    input_metric, formula_metric = card.split_metrics
    { input_metric: input_metric, formula_metric: formula_metric }
  end

  def add_metric_link input_metric, formula_metric
    args = { class: "btn btn-primary" }
    link_text = "Add this metric"
    if formula_metric.formula_card.wiki_rating?
      add_class args, "_add-weight"
      wrap_with :a, link_text, args.merge("data-metric-id" => input_metric.id)
    else
      varcard = formula_metric.formula_card.variables_card
      editor_selector =
        ".content-editor > .RIGHT-Xvariable[data-card-name='#{varcard.name}']"
      add_class args, "close-modal slotter"
      link_to_card varcard, link_text, args.merge(
        remote: true, known: true, "data-slot-selector" => editor_selector,
        path: { action: :update, add_item: input_metric.name.key }
      )
    end
  end

  def filter_fields slot_selector: nil, sort_field: nil
    super slot_selector: ".RIGHT-add_to_formula._filter-result-slot.metric_list-view"
  end

  def filter_action_path
    path mark: card.name, view: "metric_list"
  end

  view :select_modal, template: :haml

  view :metric_list, template: :haml, tags: :unknown_ok do
    class_up "card-slot", "_filter-result-slot"
  end

  view :filter_metric_list do
    wrap do
      metric_list
    end
  end

  def metric_list
    wql = { type_id: MetricID, limit: 0 }
    if card.metric_card.rated?
      wql[:right_plus] = ["*metric type", { refer_to: "Score" }]
    end
    # items = Card.search(wql)
    items = search_with_params wql
    params[:formula_metric_key] = card.name.left_key
    with_paging view: :filter_metric_list do
      wikirate_table_with_details :metric, items, [:add_to_formula_item_view],
                                  td: { classes: %w[score details] }
    end
  end
end
