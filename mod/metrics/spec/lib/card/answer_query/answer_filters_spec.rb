RSpec.describe Card::AnswerQuery::AnswerFilters do
  describe "#published_query" do
    let(:answer) { Card["Jedi+deadliness+Death_Star+1977"] }
    let :results do
      Card::AnswerQuery.new(metric_id: answer.metric_id).run
    end

    it "finds answers.unpublished = nil" do
      expect(results).to include(answer)
    end
  end
end
