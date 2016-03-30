include Type::Pointer

def metric_card
  left.left
end

def metric_card_name
  cardname.left_name.left_name
end

def formula_card
  left
end

def extract_metrics_from_formula
  update_attributes! content: formula_card.input_metrics.to_pointer.content,
                     type_id: PointerID
  formula_card.input_metrics
end

def input_metric_name variable
  index = if variable.is_a?(Integer)
            variable
          elsif variable.to_s =~ /M?(\d+)/
            $1.to_i
          end
  input_metric_name_by_index index if index
end

def to_variable_name index
  "M#{index}"
end

def input_metric_name_by_index index
  item_cards.fetch(index, nil).name
end

format :html do
  include Type::Pointer::HtmlFormat

  view :core do |args|
    args ||= {}
    items = args[:item_list] || card.item_names(context: :raw)
    items ||= extract_metrics_from_formula if items.empty?
    # items = [''] if items.empty?
    table_content =
      items.map.with_index do |item, index|
          variable_row(item, index, args)
      end
    table(table_content, header: ['Metric', 'Variable', 'Example value'])
  end

  def variable_row item_name, index, args
    item_card = Card[item_name]
    example_value =
      if (company = item_card.random_valued_company_card)
        metric_plus_company = Card["#{item_card.name}+#{company.name}"]
        subformat(metric_plus_company)._render_all_values(args)
      end
    [
      subformat(item_card)._render_thumbnail(args),
      "M#{index}", #("A".ord + args[:index]).chr
      (example_value.html_safe if example_value)
    ]
  end

  view :editor do |args|
    render_haml metric_list: metric_list do
      <<-HAML
.container-fluid.nodblclick
  .row.yinyang
    .row.yinyang-row
      .col-md-6
        .header-row
          .header-header
            Metric
        .yinyang-list
          = metric_list
      .col-md-6.metric-details
      HAML
    end
  end

  def default_edit_args args
    args[:optional_toolbar] = :hide
    args[:optional_menu] = :hide
  end

  def metric_list
    Card.search(type_id: MetricID, limit: 0).map do |m|
      metric_list_item m
    end.join "\n"
  end

  def metric_list_item metric_item_card, args={}
    # <<-HTML
    #   #{ view_link metric_card.name, :core, path_opts: {action: :update, add_item: metric_card.name }}
    # HTML
    #{card.key}+add_to_formula
    #binding.pry
    args[:append_for_details] = "#{card.metric_card_name.key}+add_to_formula"
    subformat(metric_item_card)._render_item_view(args)
  end

  view :missing  do |args|
    if @card.new_card? && (l = @card.left) &&
       l.respond_to?(:input_metrics)
      extract_metrics_from_formula
      render(args[:denied_view], args)
    else
      super(args)
    end
  end

  view :new, :missing
end