
format :html do
  def active_tab
    @active_tab ||= params[:active_tab] || (existing_answer? && "View Source")
  end

  def company_list
    @company_list ||= list_from_project_or_params(:company) || []
  end

  def metric_list
    @metric_list ||= list_from_project_or_params(:metric) || []
  end

  def year_list
    @year_list ||= list_from_project_or_params(:year) || years
  end

  def list_from_project_or_params name
    list_name = "#{name}_list"
    (params[list_name] && Array(params[list_name])) ||
      (project_card && project_card.send(list_name))
  end

  def research_url opts={}
    path_opts = { view: :slot_machine }

    %i[metric company year pinned source].each do |i|
      val = opts[i] || send(i)
      path_opts[i] = val if val
    end

    if project?
      path_opts[:project] = project
    else
      path_opts[:metric_list] = metric_list
      path_opts[:company_list] = company_list
      path_opts[:year_list] = year_list
    end
    path path_opts
  end

  def research_params
    %i[metric company year pinned source
       project metric_list company_list year_list].each_with_object({}) do |i, h|
      val = send i
      h[i] = val if val
    end
  end

  def preview_source
    params[:preview_source] || (answer? && answer_card.source_card.item_names.first)
  end

  def cited_preview_source?
    answer_card.cited? Card[preview_source]
  end

  def source
    params[:source] || (answer? && answer_card.source_card.item_names.first)
  end

  def years
    Card.search(type_id: YearID, return: :name, sort: :name, dir: :desc).map(&:to_i)
  end

  def project?
    project.present?
  end

  def project
    @project ||= Env.params[:project] || Env.params["project"]
  end

  def project_card
    return unless project?
    unless Card.exists? project
      card.errors.add :Project, "Project does not exist"
      return nil
    end
    Card.fetch(project)
  end

  def metric?
    metric && Card.fetch_type_id(metric) == MetricID
  end

  def project_year_list?
    project? && project_card.year_list.present?
  end

  def pinned
    @pinned ||= Array(Env.params[:pinned]).compact.map(&:to_sym)
  end

  def metric
    @metric ||= Env.params[:metric] || metric_list.first
  end

  def company?
    company && Card.fetch_type_id(company) == WikirateCompanyID
  end

  def answer?
    metric && company && year
  end

  def existing_answer?
    answer? && answer_card.known?
  end

  def company
    @company ||= Env.params[:company] || company_list.first
  end

  def year?
    year && Card.fetch_type_id(year) == YearID
  end

  def year
    @year ||= Env.params[:year] || (project_year_list? && year_list.first) ||
              (project? && Time.now.year.to_s)
  end

  def record_card
    @src ||= Card.fetch [metric, company], new: { type_id: RecordID }
  end

  def answer_card
    @sac ||= Card.fetch [metric, company, year.to_s], new: { type_id: MetricValueID }
  end

  def metric_pinned?
    metric_list.empty? || metric_list.one? || pinned.include?(:metric)
  end

  def company_pinned?
    company_list.empty? || company_list.one? || pinned.include?(:company)
  end

  def year_pinned?
    year_list.one? || pinned.include?(:year)
  end
end
