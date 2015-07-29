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
        expect(Card[result[0]].id).to eq(metrics_result[0].id)
        expect(Card[result[1]].id).to eq(metrics_result[2].id)
        expect(Card[result[2]].id).to eq(metrics_result[1].id)
      end
    end
    context "anonymous" do

    end
  end
  describe "Html view" do
    describe "drag and drop view" do
      before do
        @metric = Card["Jedi+deadliness"]
      end
      context "topic" do
        it "show drag and drop items" do
          topic = Card["Natural Resource Use"]
          
          # show downvotee 
          Card::Auth.current_id = Card['Joe User'].id
          Card::Auth.as_bot do
            card_to_be_voted_down = @metric.vote_count_card
            card_to_be_voted_down.vote_down
            card_to_be_voted_down.save!
          end
          voted_down_search_card = Card.fetch "#{topic.name}+metric+downvotee_search"
          html = voted_down_search_card.format.render_drag_and_drop
          expect(html).to have_tag("div",:with=>{:class=>"list-drag-and-drop yinyang-list down_vote-container","data-query"=>"vote=force-down","data-update-id"=>"Natural_Resource_Use+metric+downvotee_search","data-bucket-name"=>"down_vote"}) do
            with_tag "h5",:with=>{:class=>"vote-title"},:text=>"Not Important to Me"  
            with_tag "div",:with=>{:class=>"empty-message"} 
            with_tag("div",:with=>{:class=>"drag-item yinyang-row no-metric-value"}) do
              with_tag "div",:with=>{:id=>"Natural_Resource_Use+Jedi+deadliness+yinyang_drag_item"}
            end
          end
        end
      end
      context "company" do
        context "topic" do
          it "show drag and drop items" do
            company = Card["Apple Inc"]
            topic = Card["Force"]
            # show downvotee 
            Card::Auth.current_id = Card['Joe User'].id
            Card::Auth.as_bot do
              card_to_be_voted_down = topic.vote_count_card
              card_to_be_voted_down.vote_down
              card_to_be_voted_down.save!
            end
            voted_down_search_card = Card.fetch "#{company.name}+topic+downvotee_search"
            html = voted_down_search_card.format.render_drag_and_drop
            expect(html).to have_tag("div",:with=>{:class=>"list-drag-and-drop yinyang-list down_vote-container","data-query"=>"vote=force-down","data-update-id"=>"Apple_Inc_+topic+downvotee_search","data-bucket-name"=>"down_vote"}) do
              with_tag("div",:with=>{:class=>"drag-item yinyang-row"}) do
                with_tag "div",:with=>{:id=>"Apple_Inc_+Force+yinyang_drag_item"}
              end
            end
          end
        end
        context "metric" do
          it "show drag and drop items" do
            company = Card["Apple Inc"]
          
            # show downvotee 
            Card::Auth.current_id = Card['Joe User'].id
            Card::Auth.as_bot do
              card_to_be_voted_down = @metric.vote_count_card
              card_to_be_voted_down.vote_down
              card_to_be_voted_down.save!
            end
            voted_down_search_card = Card.fetch "#{company.name}+metric+downvotee_search"
            html = voted_down_search_card.format.render_drag_and_drop
            expect(html).to have_tag("div",:with=>{:class=>"list-drag-and-drop yinyang-list down_vote-container","data-query"=>"vote=force-down","data-update-id"=>"Apple_Inc_+metric+downvotee_search","data-bucket-name"=>"down_vote"}) do
              with_tag("div",:with=>{:class=>"drag-item yinyang-row no-metric-value"}) do
                with_tag "div",:with=>{:id=>"Apple_Inc_+Jedi+deadliness+yinyang_drag_item"}
              end
            end
          end
        end
      end
      context "analysis" do
        it "shows metric drag and drop items" do
            analysis = Card["Apple Inc+Natural_Resource_Use"]
          
            # show downvotee 
            Card::Auth.current_id = Card['Joe User'].id
            Card::Auth.as_bot do
              card_to_be_voted_down = @metric.vote_count_card
              card_to_be_voted_down.vote_down
              card_to_be_voted_down.save!
            end
            voted_down_search_card = Card.fetch "#{analysis.name}+metric+downvotee_search"
            html = voted_down_search_card.format.render_drag_and_drop
            expect(html).to have_tag("div",:with=>{:class=>"list-drag-and-drop yinyang-list down_vote-container","data-query"=>"vote=force-down","data-update-id"=>"Apple_Inc_+Natural_Resource_Use+metric+downvotee_search","data-bucket-name"=>"down_vote"}) do
              with_tag("div",:with=>{:class=>"drag-item yinyang-row no-metric-value"}) do
                with_tag "div",:with=>{:id=>"Apple_Inc_+Natural_Resource_Use+Jedi+deadliness+yinyang_drag_item"}
              end
            end
          end
      end
    end
  end
end