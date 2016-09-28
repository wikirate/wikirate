include_set Type::Pointer
include Abstract::Variable

def metric_card
  left
end

def metric_card_name
  cardname.left_name
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

format :html do
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
      if (company = item_card.try(:random_valued_company_card))
        metric_plus_company = Card["#{item_card.name}+#{company.name}"]
        subformat(metric_plus_company)._render_all_values(args)
      else
        ""
      end
    [
      subformat(item_card)._render_thumbnail(args),
      "M#{index}", # ("A".ord + args[:index]).chr
      example_value.html_safe
    ]
  end

  view :edit do |args|
    frame args do
      render_haml metric_list: metric_list do
        <<-HAML
.yinyang.nodblclick
  .row.yinyang-row
    .col-md-6
      .header-row
        .header-header
          Metric
      .yinyang-list
        = metric_list
    .col-md-6.metric-details.light-grey-color-2.text-center
      %br/
      %br/
      %br/
      %p
        Choose a metric to view more details here
      %p
        and to add it to the formula
      HAML
      end
    end
  end

  def default_edit_args args
    args[:optional_toolbar] = :hide
    args[:optional_menu] = :hide
  end

  def metric_list
    wql = { type_id: MetricID, limit: 0 }
    if card.metric_card.metric_type_codename == :wiki_rating
      wql[:right_plus] = ["*metric type", { refer_to: "Score" }]
    end
    Card.search(wql).map do |m|
      metric_list_item m
    end.join "\n"
  end

  def metric_list_item metric_item_card, args={}
    args[:append_for_details] = "#{card.metric_card_name.key}+add_to_formula"
    subformat(metric_item_card)._render_item_view(args)
  end

  view :missing  do |args|
    if @card.new_card? && (l = @card.left) &&
       l.respond_to?(:input_names)
      card.extract_metrics_from_formula
      render(args[:denied_view], args)
    else
      super(args)
    end
  end

  view :new, :missing
end
