# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Right::DownvoteeSearch do
  describe "#get_search_result" do
    context "signed in" do
      it "shows the voted cards in customized order" do
        # lets play with apple's metrics
        # vote 3 metrics related to apple
        Card::Auth.current_id = Card["Joe Camel"].id
        apple = Card["Apple Inc"]
        metrics = Card.search type_id: Card::MetricID,
                              right_plus: apple.name,
                              limit: 3
        vote_down_metrics metrics
        downvotee_search_card = apple.fetch trait: [:metric, :downvotee_search]
        result = downvotee_search_card.format.get_search_result
        expect(Card[result[0]].id).to eq(metrics[0].id)
        expect(Card[result[1]].id).to eq(metrics[2].id)
        expect(Card[result[2]].id).to eq(metrics[1].id)
      end
    end

    def vote_down_metrics metrics
      Card::Auth.as_bot do
        # just to ensure there are enough metrics to be used
        vcc = metrics.map(&:vote_count_card)
        vote_down_and_save vcc[0]
        vote_down_and_save vcc[1]
        vote_down_and_save vcc[2], metrics[1].id
      end
    end

    def vote_down_and_save metric, insert_before_id=false
      metric.vote_down insert_before_id
      metric.save!
    end

    context "anonymous" do
      context "anonymous" do
        before do
          Card::Auth.current_id = Card["Anonymous"].id
          @apple = Card["Apple Inc"]
          Card::Auth.as_bot do
            metrics = Card.search type_id: Card::MetricID,
                                  right_plus: @apple.name,
                                  limit: 3
            # just to ensure there are enough metrics to be used
            expect(metrics.length).to eq(3)
            @metrics_result = metrics
            @metrics_result.each do |metric|
              vcc = metric.vote_count_card
              vcc.vote_down
              vcc.save!
            end
          end
        end

        it "lists correct metric vote down cards" do
          metric_downvotee_search_card =
            @apple.fetch trait: [:metric, :downvotee_search]
          search_result = metric_downvotee_search_card.format.get_search_result
          @metrics_result.each do |metric|
            expect(search_result).to include(metric.name)
          end
        end

        it "lists correct topic vote down cards" do
          topic_downvotee_search_card =
            @apple.fetch trait: [:wikirate_topic, :downvotee_search]
          search_result = topic_downvotee_search_card.format.get_search_result
          expect(search_result).to be_empty
        end
      end
    end
  end
end
