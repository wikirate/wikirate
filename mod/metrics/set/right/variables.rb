include_set Type::Pointer
include_set Abstract::Variable
include_set Abstract::Table
include_set Abstract::BrowseFilterForm

def metric_card
  left
end

def metric_card_name
  name.left_name
end

def formula_card
  metric_card.fetch trait: :formula
end

def extract_metrics_from_formula
  metrics = formula_card.input_names
  Auth.as_bot do
    update_attributes! content: metrics.to_pointer_content,
                       type_id: PointerID
  end
  metrics
end

def input_metric_name variable
  index = if variable.is_a?(Integer)
            variable
          elsif variable_name? variable
            variable_index variable
          end
  input_metric_name_by_index index if index
end

def input_metric_name_by_index index
  item_cards.fetch(index, nil).name
end

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
  nil
end

format :html do
  def filter_fields slot_selector: nil, sort_field: nil
    super slot_selector: ".RIGHT-Xvariable._filter-result-slot.metric_list-view"
  end

  def filter_action_path
    path mark: card.name, view: "metric_list"
  end

  view :core do |args|
    args ||= {}
    items = args[:item_list] || card.item_names(context: :raw)
    items ||= card.extract_metrics_from_formula if items.empty?
    # items = [''] if items.empty?
    table_content =
      items.map.with_index do |item, index|
        variable_row(item, index, args)
      end
    table(table_content, header: ["Metric", "Variable", "Example value"])
  end

  def variable_row item_name, index, args
    item_card = Card[item_name]
    example_value =
      if (value = item_card.try(:random_value_card))
        nest value, view: :concise, hide: :year
      else
        ""
      end
    [
      subformat(item_card)._render_thumbnail(args),
      "M#{index}", # ("A".ord + args[:index]).chr
      example_value.html_safe
    ]
  end

  view :edit do |_args|
    voo.hide! :toolbar, :menu
    frame do
      haml do
        <<-HAML

.row.panel-margin-fix.nodblclick
  .col-md-6.left-col
    = render :filter_form
    = render :metric_list
  .col-md-6.right-col.metric-details.light-grey-color-2.text-center
    .details-slot
      %br/
      %br/
      %br/
      %p
        Choose a metric on the left to view more details here and to add it to the formula
        HAML
        end
      end
  end

  view :metric_list, template: :haml do
    class_up "card-slot", "_filter-result-slot"
  end

  def metric_list
    wql = { type_id: MetricID, limit: 0 }
    if card.metric_card.metric_type_codename == :wiki_rating
      wql[:right_plus] = ["*metric type", { refer_to: "Score" }]
    end
    # items = Card.search(wql)
    items = search_with_params
    params[:formula_metric_key] = card.name.left_key
    wikirate_table_with_details :metric, items, [:add_to_formula_item_view],
                                td: { classes: %w[score details] }
  end

  view :missing do |args|
    if @card.new_card? && (l = @card.left) &&
       l.respond_to?(:input_names)
      card.extract_metrics_from_formula
      render!(@denied_view, args)
    else
      super(args)
    end
  end

  view :new, :missing
end
