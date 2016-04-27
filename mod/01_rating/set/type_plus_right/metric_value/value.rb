

def metric
  cardname.parts[0..-4].join '+'
end

def company
  cardname.parts[-3]
end

def year
  cardname.parts[-2]
end

def metric_plus_company
   cardname.parts[0..-3].join '+'
end


def value
  content
end

def metric_card
  Card.fetch metric
end

def company_card
  Card.fetch company
end

def metric_key
  metric.to_name.key
end

def company_key
  company.to_name.key
end

def metric_plus_company_card
  Card.fetch metric_plus_company
end

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



event :update_related_scores, :finalize,
      on: [:create, :update, :delete],
      when: proc { |c| !c.metric_card.scored? } do
  metrics = Card.search type_id: MetricID,
                        left_id: metric_card.id
  metrics.each do |metric|
    metric.update_value_for! company: company_key, year: year
  end
end

event :update_related_calculations, :finalize,
      on: [:create, :update, :delete] do
  metrics = Card.search type_id: MetricID,
                        right_plus: ['formula', { refer_to: metric }]
  metrics.each do |metric|
    metric.update_value_for! company: company_key, year: year
  end
end
