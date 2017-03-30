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

def worth_counting
  return 0 unless metric_ids.any?
  yield
end

format :html do
  view :company_thumbnail do
    nest card.company_card, view: :thumbnail
  end

  view :research_button do
    link_to "Research",
            class: "btn btn-default btn-sm",
            path: { mark: :research_page,
                    company: card.company_card.name,
                    project: card.project_card.cardname.url_key }
  end
end
