include_set Abstract::ResearchBars

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
  delegate :metric_card, :company_ids, to: :card

  def units
    @units ||= "#{rate_subject} #{dataset_card.units}"
  end

  view :metric_header do
    metric_link do
      nest metric_card, view: :thumbnail_with_bookmark, hide: :thumbnail_link
    end
  end

  view :bar_left do
    render_metric_header
  end

  view :bar_middle do
    render_research_button if company_ids.present? && metric_card.researchable?
  end

  view :research_progress_bar, cache: :never do
    research_progress_bar :metric_link
  end

  def record_log_name
    company_name = (params[:company] || company_ids.first).cardname
    metric_card.name.field company_name
  end

  def full_page_card
    metric_card
  end

  def metric_link status=:all
    path_args = dataset_card.filter_path_args status
    link_to_card metric_card, yield, path: path_args, class: "metric-color"
  end
end
