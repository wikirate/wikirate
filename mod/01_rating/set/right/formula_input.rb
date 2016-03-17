include Type::Pointer

def metric_card
  left.left
end

def formula_card
  left
end

def score?
  metric_card.metric_type_codename == :score
end

def extract_metrics_from_formula
  update_attributes! content: formula_card.input_metrics.to_pointer.content,
                     type_id: PointerID
  formula_card.input_metrics
end

format :html do
  include Type::Pointer::HtmlFormat
  view :core do |args|
    args ||= {}
    items = args[:item_list] || card.item_names(context: :raw)
    items ||= extract_metrics_from_formula if items.empty?
    # items = [''] if items.empty?
    options_card_name = (oc = card.options_rule_card) ? oc.cardname.url_key : ':all'

    extra_css_class = args[:extra_css_class] #|| 'pointer-list-ul'
    output = <<-HTML
   <h4> Metrics </h4>
    <div class="row metric-info">
	    <div class="header-row">
        <div class="col-md-6 header-header">
          Metric
        </div>
        <div class="col-md-4 data-header">
          Variable
        </div>
        <div class="col-md-2 data-header">
          Exampe value
        </div>
      </div>
      <div class="col-md-12 col-xs-12">
        <ul class="metric-list-editor yinyang-list #{extra_css_class}" data-options-card="#{options_card_name}">
          #{
            items.map.with_index do |item,index|
              _render_list_item args.merge( pointer_item: item, index: index )
            end * "\n"
          }
        </ul>
        #{ _render_add_metric_button if !card.score?  }
      	<br><br>
      </div>
    </div>
    HTML
    table_content =
      items.map.with_index do |item, index|
          variable(item, index, args)
      end
    output([
      table(table_content, header: ['Metric', 'Variable', 'Example value']),
      (_render_add_metric_button if !card.score?),
      _render_modal_slot(args.merge(modal_id: card.cardname.safe_key))
    ])
  end

  def variable item_name, index, args
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

  view :edit do |args|
    <<-HTML
    <div class="container-fluid yinyang nodblclick">
    	<div class="row yinyang-row" >
        <div class="col-md-6">
          <div class="header-row">
            <div class="header-header">
              Metric
            </div>
          </div>
          <div class="yinyang-list">
            #{metric_list}
          </div>
        </div>
        <div class="col-md-6">
        </div>
      </div>
    </div>
    HTML
  end

  def metric_list
    Card.search(type_id: MetricID, limit: 20).map do |m|
      metric_list_item m
    end.join "\n"
  end

  def metric_list_item metric_item_card, args={}
    # <<-HTML
    #   #{ view_link metric_card.name, :core, path_opts: {action: :update, add_item: metric_card.name }}
    # HTML
    #{card.key}+add_to_formula
    #binding.pry
    args[:append_for_details] = "#{card.metric_card.key}+add_to_formula"
    subformat(metric_item_card)._render_item_view(args)
  end


  view :add_metric_button do |_args|
    target = "#modal-#{card.cardname.safe_key}"
    content_tag :span, class: 'input-group' do
      button_tag class: 'pointer-item-add btn btn-default slotter',
                 data: { toggle: 'modal', target: target },
                href: path(layout: 'modal', view: :edit) do
        glyphicon('plus') + ' add metric'
      end
    end

    # input_card = formula_metric.formula_card.formula_input_card
    # link_path = subformat(input_card).path(
    #   action: :update, add_item: input_metric.cardname.key
    # )
    # opts.merge!(
    #   title:           'Add metric',
    #   'data-path'      => link_path,
    #   'data-toggle'    => 'modal',
    #   'data-target'    => "#modal-#{input_card.cardname.safe_key}",
    #   class: 'button button-primary'
    # )
    # link_to 'Add this metric', hash[:path], opts
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