RSpec.describe Card::Set::TypePlusRight::Topic::TopicFamily do
  describe "#refresh_topic_family" do
    let(:topic) { topic_card "Energy" }

    def topic_name title
      [:esg_topics, title].cardname
    end

    def topic_card title
      topic_name(title).card
    end

    it "gets triggered by category change and updates family", with_user: "Joe Admin" do
      expect(topic.topic_family.cardname).to eq(topic_name(:environment))
      topic.category_card.update! content: topic_name(:social)
      expect(topic.topic_family.cardname).to eq(topic_name(:social))
    end

    # category lingers when deleted
    xit "gets deleted if there is no topic family", with_user: "Joe Admin" do
      topic.category_card.delete!
      expect(topic.topic_family_card).not_to be_real
    end
  end

  # describe "event#update_metric_topic_families" do
  #   let(:metric) { "Fred+dinosaurlabor".card } # initially tagged with taming
  #   let(:framework) { "Star Wars Topics".card }
  #   let(:metric_plus_framework ) { metric.fetch framework, new: {} }
  #
  #   it "triggers update of <metric>+<topic framework families>",
  #    with_user: "Joe Admin" do
  #     # metric_plus_framework.refresh_families
  #     # FIXME: above would not be necessary if framework were correctly assigned during
  #     # seeding.
  #     expect(metric_plus_framework.first_name).to eq(%i[esg_topics social].cardname)
  #     metric.topic_card.update! content: "Energy"
  #     expect(metric_plus_framework.refresh.item_names).to eq([%i[esg_topics environment].cardname])
  #     "Energy".card.category_card.update! content: %i[esg_topics social].cardname
  #     expect(metric_plus_framework.refresh(true).item_names).to include(%i[esg_topics social].cardname)
  #   end
  # end
end
