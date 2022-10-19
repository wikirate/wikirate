RSpec.shared_context "answer query" do
  include_context "lookup filter query", Card::AnswerQuery

  let(:default_sort) { { metric_title: :asc } }
  let(:answer_parts) { nil }

  let :latest_death_star_answers do # by metric title
    [
      "Company Category+2019", "cost of planets destroyed+1977", "darkness rating+1977",
      "deadliness+1977", "deadliness+1977", "deadliness+1977", "descendant 1+1977",
      "descendant 2+1977", "descendant hybrid+1977", "dinosaurlabor+2010",
      "disturbances in the Force+2001", "disturbances in the Force+2001",
      "double friendliness+1977", "friendliness+1977", "know the unknowns+1977",
      "more evil+1977", "researched number 1+1977", "RM+1977", "Sith Lord in Charge+1977",
      "Victims by Employees+1977"
    ]
  end

  let :researched_death_star_answers do
    [
      "cost of planets destroyed+1977", "deadliness+1977", "dinosaurlabor+2010",
      "disturbances in the Force+2001", "researched number 1+1977", "RM+1977",
      "Sith Lord in Charge+1977", "Victims by Employees+1977"
    ]
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
