RSpec.describe Card::Set::TypePlusRight::Topic::TopicFamily do
  describe "#refresh_topic_family" do
    let(:topic) { "Energy".card }

    it "gets triggered by category change and updates family", with_user: "Joe Admin" do
      # category is Force
      expect(topic.topic_family.cardname).to eq("Force")
      topic.category_card.update! content: "Taming"
      expect(topic.topic_family.cardname).to eq("Taming")
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
  #     expect(metric_plus_framework.first_name).to eq("Taming")
  #     metric.topic_card.update! content: "Energy"
  #     expect(metric_plus_framework.refresh.item_names).to eq(["Force"])
  #     "Energy".card.category_card.update! content: "Taming"
  #     expect(metric_plus_framework.refresh(true).item_names).to include("Taming")
  #   end
  # end
end
