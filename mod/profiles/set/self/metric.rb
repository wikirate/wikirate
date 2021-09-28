def ids_related_to_research_group research_group
  research_group.projects.map(&:company_ids).flatten
end

def subvariants
  {
    created: [:submitted, :designed]
  }
end

def updated_query user_id, _variant=nil
  { or: {
    updated_by: user_id,
    right_plus: [
      { name: ["in", "methodology", "about", "topics", "*metric type",
               "research policy", "report type",
               "value type", "value options", "unit", "range"] },
      { updated_by: user_id }
    ]
  } }
end

def created_query user_id, variant=nil
  case variant
  when :submitted
    { created_by: user_id }
  when :designed
    { left_id: user_id, type_id: Card::MetricID }
  else
    { or: { created_by: user_id,
            and: created_query(user_id, :designed) } }
  end
end

format :html do
  view :core, template: :haml

  view :add_button do
    link_to "Add Metric", href: "/new/Metric", class: "add-metric btn btn-secondary"
  end
end
