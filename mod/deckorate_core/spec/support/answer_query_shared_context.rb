RSpec.shared_context "answer query" do
  include_context "lookup query", Card::AnswerQuery

  let(:default_sort) { { metric_title: :asc } }
  let(:answer_parts) { nil }

  let :latest_death_star_answers do # by metric title
    [
      "Company Category+2019", "cost of planets destroyed+1977", "darkness rating+1977",
      "deadliness+1977", "deadliness+1977", "deadliness+1977", "descendant 1+1977",
      "descendant 2+1977", "descendant hybrid+1977", "dinosaurlabor+2010",
      "disturbance delta+2001",
      "disturbances in the Force+2001", "disturbances in the Force+2001",
      "double friendliness+1977", "friendliness+1977", "know the unknowns+1977",
      "more evil+1977", "researched number 1+1977", "RM+1977", "Sith Lord in Charge+1977",
      "Victims by Employees+1977"
    ]
  end

  let :latest_disturbance_answers do
    ["Death Star+2001", "Monster Inc+2000", "Slate Rock and Gravel Company+2006",
     "SPECTRE+2000"]
  end

  let :researched_death_star_answers do
    [
      "cost of planets destroyed+1977", "deadliness+1977", "dinosaurlabor+2010",
      "disturbances in the Force+2001", "researched number 1+1977", "RM+1977",
      "Sith Lord in Charge+1977", "Victims by Employees+1977"
    ]
  end

  let(:all_companies) { Card.search type: :company, return: :name }
  let :missing_disturbance_companies do
    latest_answer_keys =
      ::Set.new(latest_disturbance_answers.map { |n| n.to_name.left_name.key })
    all_companies.reject { |name| latest_answer_keys.include? name.to_name.key }
  end

  # @return [Array] of company+year strings
  def missing_disturbance_answers year=Time.now.year
    with_year missing_disturbance_companies, year
  end

  # @return [Array] of (company or metric)+year strings
  def with_year list, year=Time.now.year
    Array(list).map { |name| "#{name}+#{year}" }
  end

  def altered_results
    yield.map do |r|
      if answer_parts
        answer_parts.map { |p| r.name.parts[p] }.cardname
      else
        r.name
      end
    end
  end
end
