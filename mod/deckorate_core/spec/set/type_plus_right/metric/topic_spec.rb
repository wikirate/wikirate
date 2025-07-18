# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Metric::Topic do
  it_behaves_like "cached count", "Jedi+disturbances in the force+topics", 1, 1 do
    let(:metric) { "Jedi+disturbances in the force".card }
    let(:metric_topic) { metric.topic_card }
    let :add_one do
      metric_topic.add_item! topic("Governance")
    end
    let :delete_one do
      metric_topic.drop_item! topic(:environment)
    end

    def topic title
      [:esg_topics, title].cardname
    end
  end
end
