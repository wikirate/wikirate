# -*- encoding : utf-8 -*-
describe Card::Set::Right::DownvoteeSearch do
  describe "#get_search_result" do
    context "signed in" do
      it "shows the voted cards in customized order" do
        # lets play with apple's metrics
        # vote 3 metrics related to apple
        Card::Auth.current_id = Card['Joe User'].id
        apple = Card["Apple Inc"]
        metrics_result = nil
        Card::Auth.as_bot do
          metrics = Card.search :type_id=>Card::MetricID, :right_plus=>apple.name, :limit=>3
          # just to ensure there are enough metrics to be used
          expect(metrics.length).to eq(3)
          metrics_result = metrics
          vcc0 = metrics[0].vote_count_card
          vcc1 = metrics[1].vote_count_card
          vcc2 = metrics[2].vote_count_card
          vcc0.vote_down
          vcc0.save!
          vcc1.vote_down
          vcc1.save!
          vcc2.vote_down metrics[1].id
          vcc2.save!
        end
        metric_downvotee_search_card = Card.fetch "#{apple.name}+metric+downvotee search"
        result = metric_downvotee_search_card.item_cards
        expect(result[0].id).to eq(metrics_result[0].id)
        expect(result[1].id).to eq(metrics_result[2].id)
        expect(result[2].id).to eq(metrics_result[1].id)
      end
    end
    context "anonymous" do

    end
  end
  describe "Html view" do
    describe "drag and drop view" do
      context "topic" do
        it "show drag and drop items" do
          topic = Card["Natural Resource Use"]
          search_card = Card.fetch "#{topic.name}+metric+novotee_search"

          # show downvotee 
          Card::Auth.current_id = Card['Joe User'].id
          Card::Auth.as_bot do
            card_to_be_voted_down = Card[search_card.item_names[0]]
            card_to_be_voted_down.vote_down
            card_to_be_voted_down.save!
          end
          voted_down_search_card = Card.fetch "#{topic.name}+metric+downvotee_search"
          html = voted_down_search_card.format.render_drag_and_drop
        end
      end
      context "metric" do

      end
      context "company" do

      end
      context "analysis" do

      end
    end
    describe "filter_and_sort view" do
      context "topic" do

      end
      context "metric" do

      end
      context "company" do

      end
      context "analysis" do

      end
    end
    describe "#extract_votee" do

    end
  end
end