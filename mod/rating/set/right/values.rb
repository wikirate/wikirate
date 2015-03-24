format :html do
  def timeline_row value_card, connect=false
    year = value_card.cardname.right
    value = value_card.content
    credit = nest value_card, :view=>:content, :structure=>'creator credit'
    line = '<div class="timeline-dot"></div>'
    line += '<div class="timeline-line"></div>' if connect
    wrap_with :div, :class=>'timeline-row' do
      [
        content_tag(:div, year.html_safe, :class=>'td year'), 
        content_tag(:div, value, :class=>'td value' ),
        content_tag(:div, credit.html_safe, :class=>'td td credit'),
        (card_link "#{card.cardname.left}+#{value_card.cardname.right}+Summary",:text=>"View Sources",:class=>'btn btn-yellow btn-xs view-source-btn'),
        line
      ].compact
    end
  end
  
  def timeline_body
    search_results.map.with_index do |res,i|
      timeline_row( res, i<search_results.size-1 )
    end.join "\n"
  end
  
  view :timeline do |args|
    %{
    <div class="timeline">
      <div class="timeline-header">
        <div class="th year">
          Year
        </div>
        <div class="th value">
          Value
        </div>
        <div class="th new">
          Add New
        </div>
      </div>
      <div class="timeline-body">
        #{timeline_body}
      </div>
    </div>
    }
  end
end
