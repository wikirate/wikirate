format :html do
  def project_card
    @project_card ||= params[:project]&.card
  end

  def dataset_card
    @dataset_card ||= project_card&.dataset_card
  end

  def project_name
    project_card&.name
  end

  def project_companies_mark
    project_name&.field :wikirate_company
  end

  def project_metrics_mark
    project_name&.field :metric
  end

  def company_project_mark
    company_name.field project_name
  end

  view :company_header, template: :haml
  view :metric_header, template: :haml
  view :metric_option, template: :haml
  view :research_years, template: :haml

  view :question_phase, template: :haml, wrap: :slot
  view :methodology, template: :haml, wrap: :overlay do
    voo.hide :overlay_title
  end

  def angle dir
    fa_icon "angle-#{dir}", class: "text-secondary"
  end

  def multi_company?
    dataset_card && dataset_card.num_companies > 1
  end

  def multi_metric?
    dataset_card && dataset_card.num_metrics > 1
  end

  def link_to_company
    link_to_card company_name, nil, class: "company-color", target: "_company"
  end

  def metric_ids
    @metric_ids ||= dataset_card&.metric_ids
  end

  def metric_index
    @metric_index ||= current_metric_index
  end

  def current_metric_index
    index = metric_ids.index card.metric_id
    return index if index

    raise Error::UserError, "Metric (#{metric_name}) is not in project (#{project_name})"
  end

  def link_to_metric index, text
    record_name = metric_id_for_index(index).cardname.field card.company_name
    link_to_card record_name, text,
                 path: { project: project_name, view: :research, anchor: "metric-header" }
  end

  def metric_id_for_index index
    index.negative? ? metric_ids.last : (metric_ids[index] || metric_ids.first)
  end

  def self.all_years
    @all_years ||= Card.search type: :year, return: :name
  end

  def years
    @years ||= (dataset_card&.years || HtmlFormat.all_years).sort.reverse
  end

  def answer_for year
    answers[year.to_i] || new_answer(year)
  end

  def new_answer year
    Card.new type: :metric_answer, name: [card.record_name, year.to_s]
  end

  def answers
    @answers ||=
      card.record_card.metric_answer_card.search.each_with_object({}) do |answer, hash|
        hash[answer.year.to_i] = answer
      end
  end
end
