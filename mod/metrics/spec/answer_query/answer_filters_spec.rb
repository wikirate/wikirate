RSpec.describe Card::AnswerQuery::AnswerFilters do
  describe "#published_query" do
    def results query={}
      Card::AnswerQuery.new(query.merge(metric_id: answer.metric_id)).run
    end

    context "when user is not steward" do
      let(:answer) { Card["Jedi+deadliness+Death_Star+1977"] }

      it "implicitly finds answers.unpublished = nil" do
        expect(results).to include(answer)
      end

      it "implicitly finds answers.unpublished = false" do
        answer.unpublished_card.update! content: 0
        expect(results).to include(answer)
      end

      it "implicitly does not find answers.unpublished = true" do
        answer.unpublished_card.update! content: 1
        expect(results).not_to include(answer)
      end

      it "finds no answers when looking for unpublished" do
        answer.unpublished_card.update! content: 1
        expect(results(published: "false")).to be_empty
      end
    end

    context "when user is steward" do
      let(:answer) { Card["Joe User+RM+Apple Inc+2015"] }

      it "implicitly does not find answers.unpublished = true" do
        answer.unpublished_card.update! content: 1
        expect(results).not_to include(answer)
      end

      it "finds stewarded unpublished answer when looking for unpublished" do
        answer.unpublished_card.update! content: 1
        expect(results(published: "false").first).to eq(answer)
      end

      it "finds stewarded unpublished answer when looking for all" do
        answer.unpublished_card.update! content: 1
        expect(results(published: :all)).to include(answer)
      end
    end
  end
end
