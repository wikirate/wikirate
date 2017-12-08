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

  describe "Html view" do
    describe "drag and drop view" do
      before do
        @metric = Card["Jedi+deadliness"]
      end

      context "topic" do
        it "show drag and drop items" do
          topic = Card["Natural Resource Use"]
          @metric.update_attributes! subcards:
            { "+#{Card[:wikirate_topic].name}" => topic.name }
          # show downvotee
          Card::Auth.current_id = Card["Joe User"].id
          Card::Auth.as_bot do
            card_to_be_voted_down = @metric.vote_count_card
            card_to_be_voted_down.vote_down
            card_to_be_voted_down.save!
          end
          voted_down_search_card =
            topic.fetch trait: [:metric, :downvotee_search]
          html = voted_down_search_card.format.render_drag_and_drop
          expect(html).to have_tag("div", with:
            { class: "list-drag-and-drop yinyang-list down_vote-container",
              "data-query" => "vote=force-down",
              "data-update-id" => "Natural_Resource_Use+Metric" \
                                  "+downvotee_search",
              "data-bucket-name" => "down_vote" }) do
            with_tag "h5", with: { class: "vote-title" },
                           text: "Not Important to Me"
            with_tag "div", with: { class: "empty-message" }
            with_tag("div", with: { class: "drag-item yinyang-row" }) do
              with_tag "div", with: { id: "Natural_Resource_Use+Jedi" \
                                          "+deadliness+yinyang_drag_item" }
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
            Card::Auth.current_id = Card["Joe User"].id
            Card::Auth.as_bot do
              card_to_be_voted_down = topic.vote_count_card
              card_to_be_voted_down.vote_down
              card_to_be_voted_down.save!
            end
            voted_down_search_card =
              company.fetch trait: [:wikirate_topic, :downvotee_search]
            html = voted_down_search_card.format.render_drag_and_drop
            expect(html).to have_tag("div", with:
              { class: "list-drag-and-drop yinyang-list down_vote-container",
                "data-query" => "vote=force-down",
                "data-update-id" => "Apple_Inc+Topic+downvotee_search",
                "data-bucket-name" => "down_vote" }) do
              with_tag("div", with: { class: "drag-item yinyang-row" }) do
                with_tag "div", with:
                  { id: "Apple_Inc+Force+yinyang_drag_item" }
              end
            end
          end
        end

        context "metric" do
          it "show drag and drop items" do
            company = Card["Apple Inc"]
            subcard = {
              "+metric"  => { content: @metric.name },
              "+company" => { content: "[[#{company.name}]]",
                              type_id: Card::PointerID },
              "+value" =>   { content: "100",  type_id: Card::PhraseID },
              "+year"   =>  { content: "2015", type_id: Card::PointerID },
              "+source" => {
                "subcards" => {
                  "new source" => {
                    "+Link" => {
                      content: "http://www.google.com/?q=fringepeter",
                      type_id: Card::PhraseID
                    }
                  }
                }
              }
            }
            Card.create! type_id: Card::MetricValueID, subcards: subcard
            # show downvotee
            Card::Auth.current_id = Card["Joe User"].id
            Card::Auth.as_bot do
              card_to_be_voted_down = @metric.vote_count_card
              card_to_be_voted_down.vote_down
              card_to_be_voted_down.save!
            end
            voted_down_search_card =
              company.fetch trait: [:metric, :downvotee_search]
            html = voted_down_search_card.format.render_drag_and_drop
            expect(html).to(
              have_tag(
                "div",
                with: {
                  class: "list-drag-and-drop yinyang-list down_vote-container",
                  "data-query" => "vote=force-down",
                  "data-update-id" => "Apple_Inc+Metric+downvotee_search",
                  "data-bucket-name" => "down_vote"
                }
              ) do
                with_tag("div", with: { class: "drag-item yinyang-row" }) do
                  with_tag "div",
                           with: {
                             id: "Apple_Inc+Jedi+deadliness+yinyang_drag_item"
                           }
                end
              end
            )
          end
        end
      end

      context "analysis" do
        it "shows metric drag and drop items" do
          analysis = Card["Apple Inc+Natural_Resource_Use"]
          @metric.update_attributes! subcards:
            { "+#{Card[:wikirate_topic].name}" => analysis.name.right }
          subcard = {
            "+metric"  => { content: @metric.name },
            "+company" => { content: "[[#{analysis.name.left}]]",
                            type_id: Card::PointerID },
            "+value"   => { content: "200",  type_id: Card::PhraseID },
            "+year"    => { content: "2015", type_id: Card::PointerID },
            "+source" => {
              "subcards" => {
                "new source" => {
                  "+Link" => {
                    content: "http://www.google.com/?q=fringepeter",
                    type_id: Card::PhraseID
                  }
                }
              }
            }
          }
          Card.create! type_id: Card::MetricValueID, subcards: subcard
          # show downvotee
          Card::Auth.current_id = Card["Joe User"].id
          Card::Auth.as_bot do
            card_to_be_voted_down = @metric.vote_count_card
            card_to_be_voted_down.vote_down
            card_to_be_voted_down.save!
          end
          voted_down_search_card =
            analysis.fetch trait: [:metric, :downvotee_search]
          html = voted_down_search_card.format.render_drag_and_drop
          expect(html).to(
            have_tag(
              "div",
              with: {
                class: "list-drag-and-drop yinyang-list down_vote-container",
                "data-query" => "vote=force-down",
                "data-update-id" => "Apple_Inc+Natural_Resource_Use+Metric" \
                                    "+downvotee_search",
                "data-bucket-name" => "down_vote"
              }
            ) do
              with_tag("div", with: { class: "drag-item yinyang-row" }) do
                with_tag "div", with: { id: "Apple_Inc+Natural_Resource_Use" \
                                            "+Jedi+deadliness" \
                                            "+yinyang_drag_item" }
              end
            end
          )
        end
      end
    end
  end
end
