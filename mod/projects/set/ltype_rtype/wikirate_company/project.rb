include_set Abstract::KnownAnswers
include_set Abstract::Media

def company_card
  @company_card ||= left
end

def company_image
  company_card.fetch trait: :image, new: {}
end

def metric_ids
  project_card.metric_ids
end

def num_possible
  @num_possible ||= metric_ids.size * project_card.year_multiplier
end

def where_answer
  where_year do
    { metric_id: [:in] + metric_ids, company_id: company_card.id }
  end
end

format :html do
  view :company_thumbnail do
    company_link do
      nest card.company_card, view: :thumbnail_no_link
    end
  end

  view :research_button do
    link_to "Research",
            class: "btn btn-outline-secondary btn-sm",
            path: { mark: :research_page,
                    view: :slot_machine,
                    company: card.company_card.name,
                    pinned: :company,
                    project: project_name.url_key }
  end

  view :research_progress_bar, cache: :never, tags: :unknown_ok do
    research_progress_bar :company_link
  end

  def project_name
    card.project_card.name
  end

  def company_link values=:all
    path_args = card.project_card.filter_path_args values
    link_to_card card.company_card, yield, path: path_args, class: "company-color"
  end
end
