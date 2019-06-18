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
  project_card.company_ids
end

def num_possible
  @num_possible ||= company_ids.size * project_card.year_multiplier
end

def metric_designer_card
  metric_card.metric_designer_card
end

def metric_designer_image
  metric_designer_card.fetch(trait: :image, new: {})
end

def where_answer
  where_year do
    { metric_id: metric_card.id, company_id: [:in] + company_ids }
  end
end

format :html do
  def units
    @units ||= "#{rate_subject} #{card.project_card.units}"
  end

  view :metric_header do
    metric_link do
      nest card.metric_card, view: :thumbnail_no_link
    end
  end

  view :bar_left do
    [render_metric_header, render_project_header]
  end

  view :bar_right do
    render :research_progress_bar
  end

  view :bar_bottom do
    nest card.project_card, view: :bar_bottom
  end

  view :research_progress_bar, cache: :never do
    research_progress_bar :metric_link
  end

  view :project_header do
    nest card.project_card, view: :bar_left, hide: :default_research_progress_bar
  end

  def project_name
    card.project_card.name
  end

  def metric_link values=:all
    path_args = card.project_card.filter_path_args values
    link_to_card card.metric_card, yield, path: path_args, class: "metric-color"
  end
end
