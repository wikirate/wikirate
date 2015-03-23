format :html do
  def timeline_row value_card, connect=false
    year = value_card.cardname.right
    value = value_card.content
    credit = nest value_card, :view=>:content, :structure=>'creator credit'
    line = '<div class="timeline-dot"></div>'
    line += '<div class="timeline-line"></div>' if connect
    wrap_with :div, :class=>'timeline-row' do
      [
        content_tag(:div, year.html_safe, :class=>'year td'), 
        content_tag(:div, value, :class=>'value td' ),
        content_tag(:div, credit.html_safe, :class=>'credit td'),
        (link_to 'View Source(s)', "/#{card.left.name}+#{value_card.cardname.right}+Summary",:class=>'btn btn-yellow btn-xs view-source-btn'),
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
        <div class="item">
          Year
        </div>
        <div class="item">
          Value
        </div>
        <div class="item">
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
