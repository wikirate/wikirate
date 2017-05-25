include_set Abstract::KnownAnswers
include_set Abstract::Media

def project_card
  @project_card ||= right
end

def metric_card
  @metric_card ||= left
end

def company_ids
  project_card.company_ids
end

def num_records
  @num_records ||= company_ids.size
end

def metric_designer_card
  metric_card.metric_designer_card
end

def metric_designer_image
  metric_designer_card.fetch(trait: :image, new: {})
end

def where_answer
  { metric_id: metric_card.id, company_id: [:in] + company_ids }
end

def worth_counting
  return 0 unless company_ids.any?
  yield
end

format :html do
  view :metric_thumbnail do
    nest card.metric_card, view: :thumbnail, project: card.right.name
  end
end
