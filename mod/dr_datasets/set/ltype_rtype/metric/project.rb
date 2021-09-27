include_set Abstract::KnownAnswers
include_set Abstract::Media
include_set Abstract::FilterableBar

def virtual?
  new?
end

def metric_card
  @metric_card ||= left
end

def company_ids
  @company_ids ||= dataset_card.company_ids
end

def num_possible
  @num_possible ||= company_ids.size * dataset_card.year_multiplier
end

def metric_designer_card
  metric_card.metric_designer_card
end

def metric_designer_image
  metric_designer_card.fetch(:image, new: {})
end

def where_answer
  where_year do
    { metric_id: metric_card.id, company_id: [:in] + company_ids }
  end
end

format :html do
  delegate :metric_card, :dataset_card, :company_ids, :project_name, to: :card
  def units
    @units ||= "#{rate_subject} #{dataset_card.units}"
  end

  view :metric_header do
    metric_link do
      nest metric_card, view: :thumbnail_with_bookmark, hide: :thumbnail_link
    end
  end

  before :bar do
    voo.show :bar_middle if metric_card.researchable?
  end

  view :bar_left do
    render_metric_header
  end

  view :bar_middle do
    render_research_button
  end

  view :bar_right do
    render :research_progress_bar
  end

  view :bar_bottom do
    nest dataset_card, view: :bar_bottom
  end

  view :research_progress_bar, cache: :never do
    research_progress_bar :metric_link
  end

  view :research_button, cache: :never do
    link_to "Research",
            class: "btn btn-outline-secondary btn-sm research-answer-button",
            path: { mark: record_name, project: project_name, view: :research }
  end

  def record_name
    company_name = (params[:company] || company_ids.first).cardname
    metric_card.name.field company_name
  end

  def full_page_card
    card.dataset_card
  end

  def dataset_name
    card.dataset_card.name
  end

  def metric_link status=:all
    path_args = dataset_card.filter_path_args status
    link_to_card metric_card, yield, path: path_args, class: "metric-color"
  end
end
