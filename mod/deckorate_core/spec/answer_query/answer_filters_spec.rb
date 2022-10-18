RSpec.describe Card::AnswerQuery::AnswerFilters do
  include_context "answer query"

  describe "#published_query" do
    let(:default_filters) { { metric_id: answer.card.metric_id } }
    let(:answer) { answer_name.card }

    context "when user is not steward" do
      let(:answer_name) { "Jedi+deadliness+Death_Star+1977" }

      it "implicitly finds answers.unpublished = nil" do
        expect(search).to include(answer_name)
      end

      it "implicitly finds answers.unpublished = false" do
        answer.unpublished_card.update! content: 0
        expect(search).to include(answer_name)
      end

      it "implicitly does not find answers.unpublished = true" do
        answer.unpublished_card.update! content: 1
        expect(search).not_to include(answer_name)
      end

      it "finds no answers when looking for unpublished" do
        answer.unpublished_card.update! content: 1
        expect(search(published: "false")).to be_empty
      end
    end

    context "when user is steward" do
      let(:answer_name) { "Joe User+RM+Apple Inc+2015" }

      it "implicitly does not find answers.unpublished = true" do
        answer.unpublished_card.update! content: 1
        expect(search).not_to include(answer_name)
      end

      it "finds stewarded unpublished answer when looking for unpublished" do
        answer.unpublished_card.update! content: 1
        expect(search(published: "false").first).to eq(answer_name)
      end

      it "finds stewarded unpublished answer when looking for all" do
        answer.unpublished_card.update! content: 1
        expect(search(published: :all)).to include(answer_name)
      end
    end
  end
end
