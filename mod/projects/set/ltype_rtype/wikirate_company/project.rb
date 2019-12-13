# <Company>+<Project> handles company listings on projects' company tabs

include_set Abstract::KnownAnswers
include_set Abstract::Media
include_set Abstract::FilterableBar

def virtual?
  new?
end

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
  def units
    @units ||= "Metric #{card.project_card.units}"
  end

  bar_cols 8, 4
  info_bar_cols 6, 2, 4

  view :bar_left do
    [render_company_header, render_project_header]
  end

  view :company_header do
    company_link do
      nest card.company_card, view: :thumbnail_with_bookmark, hide: :thumbnail_link
    end
  end

  view :bar_middle do
    render :research_button
  end

  view :bar_right do
    render :research_progress_bar
  end

  view :bar_bottom do
    nest card.project_card, view: :bar_bottom
  end

  view :research_button, unknown: true do
    link_to "Research",
            class: "btn btn-outline-secondary btn-sm research-answer-button",
            path: { mark: :research_page,
                    company: card.company_card.name,
                    pinned: :company,
                    project: project_name.url_key }
  end

  view :research_progress_bar, cache: :never do
    research_progress_bar :company_link
  end

  view :project_header do
    nest card.project_card, view: :bar_left, hide: :default_research_progress_bar
  end

  def full_page_card
    card.project_card
  end

  def project_name
    card.project_card.name
  end

  def company_link values=:all
    path_args = card.project_card.filter_path_args values
    link_to_card card.company_card, yield, path: path_args, class: "company-color"
  end
end
