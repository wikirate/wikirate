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
    project_name&.field :company
  end

  def project_metrics_mark
    project_name&.field :metric
  end

  def company_project_mark
    company_name.field project_name
  end

  view :company_header, template: :haml, cache: :never
  view :metric_header, template: :haml, cache: :never
  view :metric_option, template: :haml
  view :research_years, template: :haml, cache: :never

  view :question_phase, template: :haml, wrap: :slot, cache: :never, perms: :can_research?
  view :methodology, template: :haml, wrap: :research_overlay do
    voo.hide :overlay_title
  end

  view :confirm_leave, wrap: { modal: { footer: "" } }, template: :haml do
    voo.hide :menu
  end

  view :confirm_year, wrap: { modal: { footer: "" } }, template: :haml do
    voo.hide :menu
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

  def link_to_metric rel, label, index, text=nil
    text ||= label
    record_name = metric_id_for_index(index).cardname.field card.company_name
    link_to_card record_name, text,
                 class: "_metric_arrow_button #{classy '_research-metric-link'}",
                 rel: rel,
                 title: label,
                 "aria-label": label,
                 path: { project: project_name,
                         view: :research,
                         year: params[:year],
                         anchor: "company-header" }
  end

  def metric_id_for_index index
    index.negative? ? metric_ids.last : (metric_ids[index] || metric_ids.first)
  end

  def years
    @years ||=
      dataset_card&.years? ? dataset_card.years.sort.reverse : Type::Year.all_years
  end

  def answer_for year
    answers[year.to_i] || new_answer(year)
  end

  def new_answer year
    Card.new type: :answer, name: [card.record_name, year.to_s]
  end

  def answers
    @answers ||= card.record_card.answer_card.search
                     .each_with_object({}) do |answer, hash|
      hash[answer.year.to_i] = answer
    end
  end
end
