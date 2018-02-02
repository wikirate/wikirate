
format :html do
  PARAM_NAME = { company_id_list: :cil, metric_id_list: :mil, year_list: :yil }.freeze
  def active_tab
    @active_tab ||= params[:active_tab] || (existing_answer? && "View Source")
  end

  %i[company metric year].each do |item|
    define_method "#{item}_id_list" do
      lazy_instance_variable("#{item}_id_list") { fetch_list(item) }
    end

    define_method "#{item}_list" do
      lazy_instance_variable("#{item}_list") do
        send("#{item}_id_list").map { |id| Card.fetch_name(id) }
      end
    end
  end

  def lazy_instance_variable name, &block
    name = "@#{name}" unless name.start_with? "@"
    instance_variable_get(name) || instance_variable_set(name, block.call)
  end

  def fetch_list name
    list_from_project_or_params(name) || list_default(name)
  end

  def list_default key
    key.to_sym == :year ? year_ids : []
  end

  def list_from_project_or_params name
    list_from_params(name) || list_from_project(name)
  end

  def list_from_project name
    project_card && project_card.send("#{name}_ids")
  end

  def list_from_params name
    list_name = param_name "#{name}_id_list"
    params[list_name] && Array(params[list_name])
  end

  def param_name name
    PARAM_NAME[name.to_sym] || name.to_sym
  end

  def research_url opts={}
    path_opts = { view: :slot_machine }
    research_param_keys.each do |key|
      val = opts[key] || send(key)
      path_opts[param_name(key)] = val if val
    end
    path path_opts
  end

  def research_params
    research_param_keys.each_with_object({}) do |item, h|
      val = send item
      h[param_name(item)] = val if val
    end
  end

  def research_param_keys
    keys = %i[metric company year pinned source]
    if project?
      keys << :project
    else
      keys += %i[metric_id_list company_id_list year_id_list]
    end
    keys
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

  def year_ids
    Card.search type_id: YearID, return: :id, sort: :name, dir: :desc
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
              (project? && (Time.now.year - 1).to_s)
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
