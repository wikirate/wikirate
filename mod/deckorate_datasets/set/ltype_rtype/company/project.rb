# <Company>+<Dataset> handles company listings on datasets' company tabs
include_set Abstract::ResearchBars

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
  delegate :company_card, :metric_ids, to: :card

  def units
    @units ||= card.dataset_card.units
  end

  view :bar_left do
    render_company_header
  end

  view :metrics_overview, template: :haml do
    voo.hide :menu
  end

  view :company_header do
    company_link do
      nest card.company_card, view: :thumbnail_with_bookmark, hide: :thumbnail_link
    end
  end

  view :bar_middle do
    render :research_button
  end

  view :research_progress_bar, cache: :never do
    research_progress_bar :company_link
  end

  view :research_header_progress, template: :haml

  def record_name
    metric_name = (params[:metric] || card.metric_ids.first).cardname
    metric_name.field card.company_card.name
  end

  def full_page_card
    company_card
  end

  def company_link status=:all
    path_args = card.dataset_card.filter_path_args status
    link_to_card card.company_card, yield, path: path_args, class: "company-color"
  end

  def record_names
    @record_names ||= metric_ids.map do |metric_id|
      [metric_id, company_card].cardname
    end
  end

  def record_answers record
    if dataset_card.years?
      dataset_card.years.map { |y| [record, y].cardname }
    else
      record.card.answer_card.format.search_with_params
    end
  end
end
