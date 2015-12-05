include Type::Pointer

def metric_card
  left.left
end

format :html do
  include Type::Pointer::HtmlFormat
  view :core do |args|
    args ||= {}
    items = args[:item_list] || card.item_names(context: :raw)
    items = [''] if items.empty?
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
        #{ add_item_button }
      	<br><br>
      </div>
    </div>
    HTML
    output.html_safe
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
    Card.search(type_id: MetricID).map do |m|
      metric_list_item m
    end.join "\n"
  end

  def metric_list_item metric_item_card, args={}
    # <<-HTML
    #   #{ view_link metric_card.name, :core, path_opts: {action: :update, add_item: metric_card.name }}
    # HTML
    #{card.key}+add_to_formula
    binding.pry
    args[:append_for_details] = "#{card.metric_card.key}+add_to_formula"
    subformat(metric_item_card)._render_item_view(args)
  end


  def add_item_button
    content_tag :span, class: 'input-group' do
      button_tag class: 'pointer-item-add btn btn-default slotter',
                 data: { toggle: 'modal', target: '#modal-main-slot' },
                   href: path(layout: 'modal', view: :edit) do
        glyphicon('plus') + ' add metric'
      end
    end
  end

  view :list_item do |args|
    variable = "M#{args[:index]}"#("A".ord + args[:index]).chr
    item_name = args[:pointer_item]
    item_card = Card[item_name]
    example_value =
      if (company = item_card.random_company_card_with_value)
        metric_plus_company = Card["#{item_card.name}+#{company.name}"]
        subformat(metric_plus_company)._render_all_values(args)
      end
    output = <<-HTML
      <div class="yinyang-row">
        <div class="company-item value-item">
          <div class="col-md-6">
                <a href="/{{#{item_name.to_name.left}|linkname}}" class="inherit-anchor">
      <div class="logo">
              {{#{item_name.to_name.left}+image|size:small}}
            </div>
            </a>
                <a href="/{{#{item_name}|linkname}}" class="inherit-anchor">
                <div class="name">
                    {{#{item_name.to_name.right}|name}}
                </div>
                </a>
          </div>
          <div class="col-md-2 data">
            #{variable}
          </div>
          <div class="col-md-4 data">
            #{example_value}
          </div>
        </div>
      </div>
   HTML

   process_content output
  end

  view :missing  do |args|
    if @card.new_card? && (l = @card.left) &&
       l.respond_to?(:extract_metrics)
      metrics =
        l.extract_metrics.map do |metric|
          "[[#{metric}]]"
        end
      @card.update_attributes! content: metrics, type_id: PointerID
      render(args[:denied_view], args)
    else
      super(args)
    end
  end

  view :new, :missing
end