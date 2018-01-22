
format :html do
  view :slot_machine, cache: :never do
    wrap do
      haml :slot_machine
    end
  end

  def research_url opts={}
    path_opts = {
      view: :slot_machine,
      selected_metric: opts[:metric] || selected_metric,
      selected_company: opts[:company] || selected_company,
      selected_year: opts[:year] || selected_year
    }
    if project
      path_opts[:project] = project
    else
      path_opts[:metric] = metrics
      path_opts[:company] = companies
      path_opts[:year] = years
    end
    path path_opts
  end

  def years
    Card.search(type_id: YearID, return: :name, sort: :name, dir: :desc).map(&:to_i)
  end

  def answer_tabs
    static_tabs "Research Answer" => haml(:research_answer_tab),
                "Methodology" => nest([selected_metric, :methodology]),
                "About" => nest([selected_metric, :about])
  end

  def selected_answer_view
    selected_answer_card.new_card? ? :research_form : :titled
  end

  def selected_metric
    @selected_metric ||= Env.params[:selected_metric] || metrics.first
  end

  def selected_company
    @selected_company ||= Env.params[:selected_company] || companies.first
  end

  def selected_year
    @selected_year ||= Env.params[:selected_year] || years.first
  end

  def selected_record_card
    @src ||= Card.fetch [selected_metric, selected_company], new: { type_id: RecordID }
  end

  def selected_answer_card
    @sac ||= Card.fetch [selected_metric, selected_company, selected_year.to_s],
               new: { type_id: MetricValueID }
  end

  def metric_dropdown_list
    metrics
  end

  def company_dropdown_list
    companies
  end

  def year_dropdown_list
    years
  end

  def metric_pinned?
    metrics.one?
  end

  def company_pinned?
    companies.one?
  end

  def year_pinned?
    years.one?
  end
end