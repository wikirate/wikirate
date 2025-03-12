RSpec.describe Card::Set::Type::Topic do
  include_context "topic creation"

  def card_subject
    Card["Force"]
  end

  check_views_for_errors

  describe "view: bar_left" do
    it "has topic title" do
      expect_view(:bar_left).to have_tag "div.thumbnail" do
        with_tag "div.image-box"
        with_tag "div.thumbnail-text", text: /Force/
      end
    end
  end

  describe "view: bar_right" do
    it "has counts with tab links" do
      expect_view(:bar_right).to have_badge_count(1, "RIGHT-metric", "Metrics")
      # expect_view(:bar_right).to have_badge_count(4, "RIGHT-company", "Companies")
    end
  end

  it "shows the link for view \"unknown\"" do
    html = render_card :unknown, type_id: Card::TopicID, name: "non-existing-card"
    expect(html).to eq(render_card(:link, type_id: Card::TopicID,
                                          name: "non-existing-card"))
  end

  describe "event#assign_topic_family" do
    it "adds an error if topic family is not allowed in framework" do
      expect { create_topic! "new topic", "Force", :esg_topics.cardname }
        .to raise_error(ActiveRecord::RecordInvalid,
                        /category must be in one of these families/)
    end

    it "does not apply if topic has no framework" do
      expect { create_topic! "new topic", "Force", nil }.not_to raise_error
    end

    it "does not raise error if category is acceptable" do
      expect { create_topic! "new topic", "Environment", :esg_topics.cardname }
        .not_to raise_error
      expect("new topic".card.topic_family_card.content).to eq("Environment")
    end
  end
end
