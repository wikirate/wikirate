RSpec.shared_context "answer query" do
  include_context "lookup filter query", Card::AnswerQuery

  let(:default_sort) { { metric_title: :asc } }
  let(:answer_parts) { nil }

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

