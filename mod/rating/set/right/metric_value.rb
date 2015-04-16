format :html do
  view :timeline do |args|
    timeline = output [
      (wrap_with :div, :class=>'pull-left timeline-data' do
        [
          _optional_render(:timeline_header, args.merge(:column=>:data), :show),
          (search_results.map.with_index do |res,i|
            subformat(res).render_timeline_data(args.merge(:connect=> i<search_results.size-1))
          end.join "\n")
        ]

      end),
      (wrap_with :div, :class=>'pull-left timeline-credit' do
        [
          _optional_render(:timeline_header, args.merge(:column=>:credit), :show),
          (search_results.map.with_index do |res,i|
            subformat(res).render_timeline_credit(args.merge(:connect=> i<search_results.size-1))
          end.join "\n")
        ]
      end),
    ]
    %{
      <div class="timeline">
        <div class="timeline-body">
          #{timeline}
        </div>
      </div>
    }
  end

  view :timeline_add_new_link do |args|
    timeline_head card_link(card.left, :text=>'+ Add New'), 'new'
  end

  view :timeline_header do |args|
    wrap_with :div, :class=>'timeline-header' do
      case args[:column]
      when :credit
        _optional_render(:timeline_add_new_link, args, :show) || ''
      when :data
        timeline_head('Year','year')+timeline_head('Value','value')
      else ''
      end
    end
  end

  def timeline_head content, css_class
    %{
      <div class="th #{css_class}">
        #{content}
      </div>
    }
  end
end