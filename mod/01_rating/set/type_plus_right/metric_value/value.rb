include_set Abstract::MetricChild, generation: 3


def company
  cardname.parts[-3]
end

def year
  cardname.parts[-2]
end

def metric_plus_company
  cardname.parts[0..-3].join "+"
end

def value
  content
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

def unknown_value?
  content.casecmp("unknown") == 0
end

def option_names metric_name
  # value options
  metric_name = metric unless metric_name.present?
  option_card = Card.fetch "#{metric_name}+value options", new: {}
  option_card.item_names context: :raw
end

format :html do
  def metric_name_from_params
    Env.params[:slot][:metric] if Env.params[:slot]
  end

  view :select do |args|
    options = [["-- Select --", ""]] +
              card.option_names(args[:metric_name]).map { |x| [x, x] }
    select_tag("card#{subcard_input_names}[content]",
               options_for_select(options),
               class: "pointer-select form-control")
  end

  view :editor do |args|
    if (metric_name = metric_name_from_params || card.metric) &&
       (metric_card = Card[metric_name]) &&
       metric_card.value_type == "Category"
      _render_select(args.merge(metric_name: metric_name))
    else
      super(args)
    end
  end

  view :timeline_row do |args|
    args[:hide] = "timeline_header timeline_add_new_link"
    wrap_with :div, class: "timeline container" do
      wrap_with :div, class: "timeline-body" do
        [
          (wrap_with :div, class: "pull-left timeline-data" do
            subformat(card.left).render_timeline_data(args)
          end)
        ]
      end
    end
  end
end

event :update_related_scores, :finalize,
      on: [:create, :update, :delete],
      when: proc { |c|
        c.metric_card.type_id == MetricID &&
          !c.metric_card.scored?
      } do
  metrics = Card.search type_id: MetricID,
                        left_id: metric_card.id
  metrics.each do |metric|
    metric.update_value_for! company: company_key, year: year
  end
end

event :update_related_calculations, :finalize,
      on: [:create, :update, :delete] do
  metrics = Card.search type_id: MetricID,
                        right_plus: ["formula", { refer_to: metric }]
  metrics.each do |metric|
    metric.update_value_for! company: company_key, year: year
  end
end
