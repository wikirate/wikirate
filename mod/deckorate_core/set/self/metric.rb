include_set Abstract::CachedCount

recount_trigger :type, :metric, on: [:create, :delete] do |_changed_card|
  Card[:metric]
end

def count
  MetricQuery.new({}).count
end

format :html do
  view :core, template: :haml

  view :add_button do
    link_to "Add Metric", href: "/new/Metric", class: "add-metric btn btn-secondary"
  end
end
