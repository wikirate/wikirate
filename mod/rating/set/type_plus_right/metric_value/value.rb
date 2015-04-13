format :html do
  view :timeline_row do |args|
    args.merge!(:hide=>'timeline_header source_link timeline_add_new_link')
    wrap_with :div, :class=>'timeline' do
      wrap_with :div, :class=>'timeline-body' do
        [
          (wrap_with :div, :class=>'pull-left timeline-data' do
            subformat(card.left).render_timeline_data(args)
          end),
          (wrap_with :div, :class=>'pull-left timeline-credit' do
            subformat(card.left).render_timeline_credit(args)
          end)
        ]
      end
    end
  end
end