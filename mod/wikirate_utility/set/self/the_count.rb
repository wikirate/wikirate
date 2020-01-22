format :html do
  def years
    res = Env.params[:years] || [2017, 2018, 2019]
    Array.wrap res
  end

  ROW_TITLES = {
    user: "Users",
    metric: "Metrics",
    research_group: "Research Groups",
    project: "Projects",
    designer: "Metric Designers"
  }.freeze

  ROWS = ROW_TITLES.keys.freeze

  view :table do
    table table_rows, header: years.map { |y| "1/1/#{y}" }.unshift("").unshift("")
  end

  def table_rows
    rows = []
    ROW_TITLES.each do |name, title|
      rows << [title, ""] + years.map { |year| send "#{name}_count", year }
      more_rows = try("#{name}_rows")
      rows += more_rows if more_rows
    end
    rows
  end

  def project_rows
    Card.search(referred_to_by: { left: { type_id: Card::ProjectID },
                                  right: { codename: "organizer" } },
                return: "name").map do |organizer|
      ids = Card.search(type_id: Card::ProjectID,
                        right_plus: ["organizer", refer_to: organizer], return: "id")
      ["", organizer] + years.map { |year| id_search(ids, year) }
    end
  end

  def designer_rows
    designer_ids.map do |id|
      ["", Card.fetch_name(id)] + years.map { |year| metric_count_by_designer(id, year) }
    end
  end

  def metric_count_by_designer id, year
    Card.where("left_id = ? and created_at < ? and type_id = ?",
               id, Time.new(year), Card::MetricID).count
  end

  def user_count year
    type_search Card::UserID, year
  end

  def project_count year
    type_search Card::ProjectID, year
  end

  def metric_count year
    type_search Card::MetricID, year
  end

  def research_group_count year
    type_search Card::ResearchGroupID, year
  end

  def designer_count year
    id_search designer_ids, year
  end

  def designer_ids
    Card.search(right_plus: [{}, { type_id: Card::MetricID }], not: { type_id: Card::MetricID },
                return: "id")
  end

  def id_search ids, year
    Card.where("id in (?) and created_at < ?", ids, Time.new(year)).count
  end

  def type_search type_id, year
    Card.where("type_id = ? and created_at < ?", type_id, Time.new(year)).count
  end
end
