include Type::Pointer

format :html do
  include Type::Pointer::HtmlFormat
  view :core do |args|
    args ||= {}
    binding.pry
    items = args[:item_list] || card.item_names(context: :raw)
    items = [''] if items.empty?
    options_card_name = (oc = card.options_rule_card) ? oc.cardname.url_key : ':all'

    extra_css_class = args[:extra_css_class] #|| 'pointer-list-ul'

    output = <<-HTML
   <h4> Metrics </h4>
    <div class="row metric-info">
	    <div class="header-row">
        <div class="header-header">
          Metric
        </div>
        <div class="data-header">
          Exampe value
        </div>
        <div class="data-header">
          Variable
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

  def add_item_button
    content_tag :span, class: 'input-group' do
      button_tag class: 'pointer-item-add' do
        glyphicon('plus') + ' add metric'
      end
    end
  end

  view :list_item do |args|
    variable = "M#{args[:index]}"#("A".ord + args[:index]).chr
    output = <<-HTML
      <div class="yinyang-row">
        <div class="company-item value-item">
          <div class="header">
                <a href="/{{_llr|linkname}}" class="inherit-anchor">
      <div class="logo">
              {{_llr+image|core;size:small}}
            </div>
            </a>
                <a href="/{{_llr|linkname}}" class="inherit-anchor">
                <div class="name">
                    {{_llr|name}}
                </div>
                </a>
          </div>
          <div class="data">
            {{_ll|all_values}}
          </div>
          <div class="data">
            #{variable}
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