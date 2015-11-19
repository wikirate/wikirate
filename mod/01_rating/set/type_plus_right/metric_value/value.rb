format :html do
  view :timeline_row do |args|
    args.merge! hide: 'timeline_header timeline_add_new_link'
    wrap_with :div, class: 'timeline container' do
      wrap_with :div, class: 'timeline-body' do
        [
          (wrap_with :div, class: 'pull-left timeline-data' do
            subformat(card.left).render_timeline_data(args)
          end)
        ]
      end
    end
  end
end

def company_name
  cardname.left_name.left_name.right
end

event :update_related_calculations, after: :store do
  metrics = Card.search left: { type_id: MetricID },
                        right_plus: ['formula', { refer_to: name }]

  metrics.each do |metric|
    metric.update_value_for_company! company_name
  end
end
