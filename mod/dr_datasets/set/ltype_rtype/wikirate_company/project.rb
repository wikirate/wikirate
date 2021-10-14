# <Company>+<Dataset> handles company listings on datasets' company tabs

include_set Abstract::KnownAnswers
include_set Abstract::Media
include_set Abstract::FilterableBar

def virtual?
  new?
end

def company_card
  @company_card ||= left
end

def metric_ids
  @metric_ids ||= dataset_card.metric_ids
end

def num_possible
  @num_possible ||= metric_ids.size * dataset_card.year_multiplier
end

def where_answer
  where_year do
    { metric_id: [:in] + metric_ids, company_id: company_card.id }
  end
end

format :html do
  def units
    @units ||= card.dataset_card.units
  end

  bar_cols 8, 4
  info_bar_cols 6, 2, 4

  view :bar_left do
    render_company_header
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
    nest card.dataset_card, view: :bar_bottom
  end

  view :research_button, cache: :never do
    link_to "Research",
            class: "btn btn-outline-secondary btn-sm research-answer-button",
            path: { mark: record_name, project: card.project_name, view: :research }
  end

  view :research_progress_bar, cache: :never do
    research_progress_bar :company_link
  end

  view :research_header_progress, template: :haml

  def record_name
    metric_name = (params[:metric] || card.metric_ids.first).cardname
    metric_name.field card.company_card.name
  end

  def dataset_name
    card.dataset_card.name
  end

  def company_link status=:all
    path_args = card.dataset_card.filter_path_args status
    link_to_card card.company_card, yield, path: path_args, class: "company-color"
  end
end
