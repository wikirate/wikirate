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

format :html do

  view :concise do |args|
    legend = subformat(card.metric_card)._render_legend args
    %{
      <span class="metric-year">
        #{card.year} =
      </span>
      <span class="metric-value">
        #{card.value}
      </span>
      <span class="metric-unit">
        #{legend}
      </span>
    }
  end

  view :timeline_data do |args|
    year  =  content_tag(:span, card.cardname.right, :class=>'metric-year')
    value = ((value_card = card.fetch(:trait=>:value)) && value_card.content) || ''
    value =  content_tag(:span, value, :class=>'metric-value')
    value << content_tag(:span, subformat(card[0..1])._render_legend(), :class=>'metric-unit')

    line   =  content_tag(:div, '', :class=>'timeline-dot')
    line   << content_tag(:div, '', :class=>'timeline-line') if args[:connect]

    wrap_with :div, :class=>'timeline-row' do
      [
        line,
        content_tag(:div, year,             :class=>'td year'),
        content_tag(:div, value.html_safe,  :class=>'td value' ),
      ]
    end
  end

  view :timeline_credit do |args|
    wrap_with :div, :class=>'timeline-row' do
      wrap_with :div, :class=>'td credit' do
        [
          nest(card, :view=>:content, :structure=>'creator credit'),
          _optional_render(:source_link, args, :show)
        ]
      end
    end
  end

  view :source_link do |args|
    source_link =  card_link card.name,
                            :text=>"View Sources", :class=>'btn btn-yellow btn-xs view-source-btn show-link-in-popup popup-original-link no-header',
                            "data-popup-title"=>card.name
    content_tag(:p, source_link)
  end

end
