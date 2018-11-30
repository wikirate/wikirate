
format do
  PARAM_LIST_NAME =
    { company_id_list: :cil, metric_id_list: :mil, year_id_list: :yil }.freeze

  def active_tab
    @active_tab ||= params[:active_tab] || (answer? && "Sources") || "Metric details"
  end

  %i[company metric year].each do |item|
    define_method "#{item}_id_list" do
      lazy_instance_variable("#{item}_id_list") { fetch_list(item) }
    end

    define_method "#{item}_list" do
      lazy_instance_variable("#{item}_list") do
        send("#{item}_id_list").map { |id| id && Card.fetch_name(id.to_i) }.compact
      end
    end
  end

  def lazy_instance_variable name
    name = "@#{name}" unless name.start_with? "@"
    instance_variable_get(name) || instance_variable_set(name, yield)
  end

  def fetch_list name
    list_from_project_or_params(name) || list_default(name)
  end

  def list_default key
    @default_list_used ||= ::Set.new
    @default_list_used << key
    key.to_sym == :year ? year_ids : []
  end

  def default_list_used? list_key
    @default_list_used&.include? list_key
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
    PARAM_LIST_NAME[name.to_sym] || name.to_sym
  end

  def research_url opts={}
    path_opts = { view: :slot_machine, rp: {} }
    research_param_keys.each do |key|
      val = opts[key] || send(key)
      path_opts[:rp][param_name(key)] = val if val
    end
    path path_opts
  end

  def research_param key
    Env.params.dig(:rp, key.to_sym) || Env.params.dig("rp", key.to_s) || Env.params[key]
  end

  def research_params
    @research_params ||=
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
      keys += PARAM_LIST_NAME.keys.reject do |k|
        fetch_list(k).empty? || default_list_used?(k)
      end
    end
    keys
  end

  def preview_source
    research_param(:preview_source) ||
      (answer? && answer_card.source_card.item_names.first)
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
    @project ||= research_param :project
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
    @pinned ||= Array(research_param(:pinned)).compact.map(&:to_sym)
  end

  def metric
    @metric ||= research_param(:metric) || metric_list.first
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

  def researchable_answer?
    answer_card&.metric_card&.researchable?
  end

  def existing_answer_with_source?
    existing_answer? && researchable_answer? &&
      (answer_card.researched? || answer_card.researched_value?)
  end

  def company
    @company ||= research_param(:company) || company_list.first
  end

  def related_company
    @related_company ||= research_param(:related_company)
  end

  def year?
    year && Card.fetch_type_id(year) == YearID
  end

  def year
    @year ||= research_param(:year) || (project_year_list? && year_list.first) ||
              (project? && (Time.now.year - 1).to_s)
  end

  def record_card
    @src ||= Card.fetch [metric, company], new: { type_id: RecordID }
  end

  def answer_card
    @sac ||=
      if related_company
        Card.fetch [metric, company, year.to_s, related_company],
                   new: { type_id: RelationshipAnswerID }
      else
        Card.fetch [metric, company, year.to_s], new: { type_id: MetricAnswerID }
      end

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
