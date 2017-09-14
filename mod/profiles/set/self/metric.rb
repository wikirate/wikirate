def ids_related_to_research_group research_group
  research_group.projects.map(&:company_ids).flatten
end

def subvariants
  {
    created: [:submitted, :designed],
    voted_on: [:voted_for, :voted_against]
  }
end

def updated_query user_id, _variant=nil
  { or: {
    updated_by: user_id,
    right_plus: [
      { name: ["in", "methodology", "about", "topics", "*metric type",
               "research policy", "report type",
               "value type", "value options", "unit", "range", "currency"] },
      { updated_by: user_id }
    ]
  } }
end

def created_query user_id, variant=nil
  case variant
  when :submitted
    { created_by: user_id }
  when :designed
    { left_id: user_id, type_id: MetricID }
  else
    { or: { created_by: user_id,
            and: created_query(user_id, :designed) } }
  end
end
