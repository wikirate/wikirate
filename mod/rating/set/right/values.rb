format :html do
  def timeline_row value_card, connect=false
    year        = value_card.cardname.right
    value       = value_card.content
    source_link = card_link "#{card.cardname.left}+#{value_card.cardname.right}+Summary",:text=>"View Sources",:class=>'btn btn-yellow btn-xs view-source-btn'
    credit =  nest(value_card, :view=>:content, :structure=>'creator credit')
    credit << content_tag(:p, source_link)
    line   =  content_tag(:div, :class=>'timeline-dot')
    line   << content_tag(:div, :class=>'timeline-line') if connect

    wrap_with :div, :class=>'timeline-row' do
      [
        line,
        content_tag(:div, year, :class=>'td year'),
        content_tag(:div, value, :class=>'td value' ),
        content_tag(:div, credit.html_safe, :class=>'td credit'),
      ]
    end
  end
  
  view :timeline do |args|
    search_results.map.with_index do |res,i|
      timeline_row( res, i<search_results.size-1 )
    end.join "\n"
  end
end
