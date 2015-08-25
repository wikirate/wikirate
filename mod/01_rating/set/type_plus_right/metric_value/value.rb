format :html do
  view :timeline_row do |args|
    args.merge!(:hide=>'timeline_header timeline_add_new_link')
    wrap_with :div, :class=>'timeline container' do
      wrap_with :div, :class=>'timeline-body' do
        [
          (wrap_with :div, :class=>'pull-left timeline-data' do
            subformat(card.left).render_timeline_data(args)
          end)
        ]
      end
    end
  end
end