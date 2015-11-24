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

def metric_name
  cardname.left_name.left_name.left
end

def company_name
  cardname.left_name.left_name.right
end

event :update_related_calculations,
      after: :store,
      on: [:create, :update, :delete] do
  metrics = Card.search type_id: MetricID,
                        right_plus: ['formula', { refer_to: metric_name }]

  metrics.each do |metric|
    metric.update_value_for_company! company_name
  end
end
