include_set Abstract::KnownAnswers
include_set Abstract::Media

def project_card
  @project_card ||= right
end

def company_card
  @company_card ||= left
end

def company_image
  company_card.fetch(trait: :image, new: {})
end

def metric_ids
  project_card.metric_ids
end

def num_records
  @num_records ||= metric_ids.size
end

def where_answer
  { metric_id: [:in] + metric_ids, company_id: company_card.id }
end

def worth_counting?
  metric_ids.any?
end

format :html do
  view :company_thumbnail do
    nest card.company_card, view: :thumbnail_no_link
  end

  view :research_button do
    link_to "Research",
            class: "btn btn-outline-secondary btn-sm",
            path: { mark: :research_page,
                    company: card.company_card.name,
                    project: card.project_card.name.url_key }
  end

  view :research_progress_bar do
    link_to_card card.company_card, _render_absolute_research_progress_bar,
                 path: { filter: { project: card.project_card.name,
                                   metric_value: :all } }
  end
end
