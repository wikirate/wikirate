card_accessor :value, :type=>:phrase

def year
  cardname.right
end

def metric_name
  cardname.left_name.left
end

def company_name
  cardname.left_name.right
end

def metric_card
  Card.fetch metric_name
end

def company_card
  Card.fetch company_name
end


event :set_metric_value_name, :before=>:set_autoname do
  self.name = ['+metric', '+company', '+year'].map do |name|
      subcards.delete(name)['content'].gsub('[[','').gsub(']]','')
    end.join '+'
end

event :create_source_for_metric_value, :after=>:validate_name, :on=>:save do
  Env.params[:sourcebox] = 'true'
  value = subcards.delete('+value')
  source_card = Card.create :type_id=>Card::SourceID, :subcards=>subcards
  Env.params[:sourcebox] = nil
  if source_card.errors.empty?
    @subcards = {
      '+value' => value,
      '+source' => {:content=>"[[#{source_card.name}]]"}
    }
  else
    source_card.errors.each do |key,value|
      errors.add key,value
    end
  end
end



format :html do
  def default_new_args args
    args[:hidden] = {
      :success=>{:id=>'_self', :soft_redirect=>true, :view=>:titled},
      'card[subcards][+metric][content]' => args[:metric]
    }

    if args[:company]
      args[:hidden]['card[subcards][+company][content]'] = args[:company]
    end
    args[:structure] =
      if args[:company]
        'metric company add value'
      else
        'metric add value'
      end
    super(args)
  end

  def legend args
    subformat(card.metric_card)._render_legend args
  end

  view :concise do |args|
    %{
      <span class="metric-year">
        #{card.year} =
      </span>
      #{_render_modal_details(args)}
      <span class="metric-unit">
        #{legend(args)}
      </span>
    }
  end

  view :modal_details do |args|
    modal_link = subformat(card)._render_modal_link(args.merge(:text=>card.value, :path_opts=>{:slot=>{:show=>:menu,:optional_horizontal_menu=>:hide}})) #,:html_args=>{:class=>"td year"}))
    %{
      <span class="metric-value">
        #{modal_link}
      </span>
    }
  end

  view :timeline_data do |args|
    year  =  content_tag(:span, card.cardname.right, :class=>'metric-year')
    value_card = card.fetch(:trait=>:value)
    #value = ((value_card = card.fetch(:trait=>:value)) && value_card.content) || ''
    #value = nest value_card
    value =  _render_modal_details(args) # content_tag(:span, value, :class=>'metric-value')
    value << content_tag(:span, legend(args), :class=>'metric-unit')

    line   =  content_tag(:div, '', :class=>'timeline-dot')
    line   << content_tag(:div, '', :class=>'timeline-line') if args[:connect]



    wrap_with :div, :class=>'timeline-row' do
      [
        line,
        content_tag(:div, year.html_safe,  :class=>'td year'),
        content_tag(:div, value.html_safe, :class=>'td value' ),
      ]
    end
  end

  view :timeline_credit do |args|
    wrap_with :div, :class=>'timeline-row' do
      wrap_with :div, :class=>'td credit' do
        [
          nest(card, :view=>:content, :structure=>'creator credit'),
          _optional_render(:source_link, args, :hide)
        ]
      end
    end
  end

  view :source_link do |args|
    if source_card = card.fetch(:trait=>:wikirate_source)
      source_card.item_cards.map do |i_card|
        subformat(i_card).render_original_icon_link
      end.join "\n"
    else
      ''
    end
#    source_link = subformat(card)._render_modal_link(args.merge(:text=>'View Sources',:html_args=>{:class=>"btn btn-yellow btn-xs"}))
#    content_tag(:p, source_link+subformat(card)._render_modal_slot(args))
  end

end
