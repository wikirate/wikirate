def ids_related_to_research_group research_group
  research_group.projects.map do |project|
    Answer.where(
      company_id: project.company_ids,
      metric_id: project.metric_ids
    ).pluck :answer_id
  end.flatten
end
