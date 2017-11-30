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

def worth_counting?
  company_ids.any?
end

format :html do
  view :metric_thumbnail do
    metric_link do
      nest card.metric_card, view: :thumbnail_no_link
    end
  end

  view :research_progress_bar, cache: :never do
    research_progress_bar :metric_link
  end

  def project_name
    card.project_card.name
  end

  def metric_link values = :all
    path_args = { filter: { project: project_name, metric_value: values } }
    link_to_card card.metric_card, yield, path: path_args
  end
end
