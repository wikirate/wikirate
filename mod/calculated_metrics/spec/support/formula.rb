shared_context "formula" do
  def formula_str options: nil, method: nil, year: nil, unknown: nil, company: nil,
              metric: "Joe User+RM", related: nil, add: nil
    res = "{{#{metric}"
    year = "year:#{year}" if year
    unknown = "unknown: #{unknown}" if unknown
    company = "company: #{company}" if company
    company = "company: Related[#{related}]" if related
    options = [year, unknown, company].compact.join("; ") unless options
    res += "| #{options}" if options.present?
    res += "}}"
    res = "#{method}[#{res}]" if method
    res = "#{res}+#{formula_str(add)}" if add
    res
  end

  # Create a formula metric with formula
  # METHOD[{{METRIC | year: YEAR; unknown: UNKNOWN; company: COMPANY}}]
  # if options is given
  # # METHOD[{{METRIC | OPTIONS }}]
  # the option "add" can th
  def create_formula_metric formula: nil,
                            metric: "Joe User+RM", options: nil,
                            method: nil, year: nil, unknown: nil, company: nil,
                            related: nil,
                            add: nil
    formula ||= formula_str(options: options, method: method, year: year, unknown: unknown,
                          company: company, metric: metric, add: add, related: related)
    # puts formula
    create_metric name: "Jedi+formula1", type: :formula, formula: formula
  end

  def take_answer_value company, year=1977
    company_id = Card.fetch_id company unless company_id.is_a?(Integer)
    Answer.where(metric_name: "Jedi+formula1", company_id: company_id, year: year)
          .take&.value
  end

end
