describe Card::Set::TypePlusRight::WikirateCompany::AllMetricValues::Filter do
  let(:company) do
    Card.create! name: "new company", type_id: Card::WikirateCompanyID
  end
  let(:all_metric_values) { company.fetch trait: :all_metric_values }
  let(:metrics) do
    [Card["Jedi+Sith Lord in Charge"],
     Card["Joe User+researched number 1"],
     Card["Joe User+researched number 2"],
     Card["Joe User+researched number 3"],
     Card["Jedi+darkness rating"]]
  end

  def initialize_params
    %w(name industry project year metric_value).each do |param|
      Card::Env.params[param] = ""
    end
  end

  def add_filter key, value
    Card::Env.params[key.to_s] = value
  end

  before do
    metrics.each.with_index do |metric, value_idx|
      0.upto(3) do |i|
        metric.create_value company: company.name,
                            value: (value_idx + 1) * 5 + i,
                            year: 2015 - i,
                            source: sample_source.name
      end
    end
    initialize_params
  end

  describe "#filter" do
    subject { all_metric_values.filtered_values_by_name }

    def expect_result_count cnt
      expect(subject.size).to eq(cnt)
    end

    def expect_first_result key
      expect(subject.keys[0]).to eq(key)
    end

    it "filters by name" do
      add_filter :name, "number"
      expect_result_count 3
      subject.keys.each do |metric|
        expect(metric).to include("number")
      end
    end

    it "filters by topic" do
      Card.create! name: "Joe User+researched number 1+topic",
                   content: "[[Force]]\n"
      add_filter :wikirate_topic, "Force"
      expect_result_count 1
      expect_first_result "Joe User+researched number 1"
    end

    it "filters by research policy" do
      Card.create! name: "Joe User+researched number 1+research_policy",
                   content: "[[Designer Assessed]]\n"
      add_filter :research_policy, ["Designer Assessed"]
      expect_result_count 1
      expect_first_result "Joe User+researched number 1"
    end

    it "filters by vote" do
      Card::Auth.current_id = Card["Joe User"].id
      Card::Auth.as_bot do
        vcc = Card["Joe User+researched number 1"].vote_count_card
        vcc.vote_up
        vcc.save!
      end
      add_filter :importance, "i voted for"
      expect_result_count 1
      expect_first_result "Joe User+researched number 1"
    end

    it "filters by value" do
      pending
      Card::Auth.as_bot do
        Card.create! name: "Joe User+empty metric", type_id: Card::MetricID,
                     subcards: { "+#{company.name}" => {} }
      end
      add_filter :metric_value, "none"
      # metrics.each do |metric|
      #   expect(subject.keys).not_to include(metric.name)
      # end
      expect(subject.keys).to eq ["Joe User+empty metric"]
      # all_metrics = Card.search type_id: Card::MetricID
      # all_metrics.each do |m|
      #   next if metrics.include?(m)
      #   expect(subject.keys).to include(m.name)
      # end
    end

    it "filters by type" do
      add_filter :type, ["wikirating"]
      expect_result_count 1
      expect_first_result "Jedi+darkness rating"
    end
  end
end
