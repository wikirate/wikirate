shared_context "formula" do
  def formula_str options: nil, method: nil, year: nil, unknown: nil, company: nil,
                  metric: "Joe User+RM", related: nil, add: nil
    nest_values = [year, unknown, company, related]
    res = "{{#{metric}#{nest_options options, nest_values}}}"
    res = "#{method}[#{res}]" if method
    res = "#{res}+#{formula_str(**add)}" if add
    res
  end

  def nest_options options, nest_values
    options ||= implicit_nest_options(*nest_values)
    format_nest_options options.compact
  end

  def implicit_nest_options year, unknown, company, related
    {
      "year: %s" => year,
      "unknown: %s" => unknown,
      "company: %s" => company,
      "company: Related[%s]" => related
    }.each_with_object([]) do |(clause, option), options|
      add_option_if_exists options, clause, option
    end
  end

  def format_nest_options options
    return unless options.present?

    "| #{options.join ';'}"
  end

  def add_option_if_exists array, clause, option
    return unless option
    array << (clause % option.to_s)
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
    formula ||= formula_str(
      options: options, method: method, year: year, unknown: unknown,
      company: company, metric: metric, add: add, related: related
    )
    # puts formula
    create_metric name: "Jedi+formula1", type: :formula, formula: formula
  end

  def take_answer_value company, year=1977
    company_id = company.card_id unless company_id.is_a?(Integer)
    Answer.where(metric_id: "Jedi+formula1".card_id, company_id: company_id, year: year)
          .take&.value
  end
end
