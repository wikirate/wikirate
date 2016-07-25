describe Card::Set::TypePlusRight::WikirateCompany::AllMetricValues do
  let(:company) do
    Card.create! name: "new company", type_id: Card::WikirateCompanyID
  end
  let(:all_values) { company.fetch trait: :all_metric_values }
  let(:metrics) do
    [Card["Jedi+Sith Lord in Charge"],
     Card["Joe User+researched number 1"],
     Card["Joe User+researched number 2"],
     Card["Joe User+researched number 3"],
     Card["Jedi+darkness rating"]]
  end
  def initialize_params
    %w(name industry project year value).each do |param|
      Card::Env.params[param] = ""
    end
  end
  before do
    metrics.each.with_index do |metric, value_idx|
      0.upto(3) do |i|
        metric.create_value company: company.name,
                            value: (value_idx + 1) * 5 + i,
                            year: 2015 - i,
                            source: get_a_sample_source.name
      end
    end
    initialize_params
  end
  describe "#get_cached_values" do
    it "returns correct cached metric values" do
      results = all_values.get_cached_values
      value_idx = 1
      metrics.each do |metric|
        expect(results.key?(metric.name)).to be_truthy
        0.upto(3) do |i|
          found_expected = results[metric.name].any? do |row|
            row[:year] == (2015 - i).to_s &&
              row[:value] == (value_idx * 5 + i).to_s
          end
          expect(found_expected).to be_truthy
        end
        value_idx += 1
      end
    end
  end
  describe "#filter" do
    it "filters by name" do
      Card::Env.params["name"] = "number"
      results = all_values.cached_values
      expect(results.size).to eq(3)
      results.keys.each do |metric|
        expect(metric).to include("number")
      end
    end

    it "filters by topic" do
      Card.create! name: "Joe User+researched number 1+topic",
                   content: "[[Force]]\n"
      Card::Env.params["wikirate_topic"] = "Force"
      results = all_values.cached_values
      expect(results.size).to eq(1)
      expect(results.keys[0]).to eq("Joe User+researched number 1")
    end

    it "filters by research policy" do
      Card.create! name: "Joe User+researched number 1+research_policy",
                   content: "[[Designer Assessed]]\n"
      Card::Env.params["research_policy"] = ["Designer Assessed"]
      results = all_values.cached_values
      expect(results.size).to eq(1)
      expect(results.keys[0]).to eq("Joe User+researched number 1")
    end

    it "filters by vote" do
      Card::Auth.current_id = Card["Joe User"].id
      Card::Auth.as_bot do
        vcc = Card["Joe User+researched number 1"].vote_count_card
        vcc.vote_up
        vcc.save!
      end
      Card::Env.params["my_vote"] = "upvoted"
      results = all_values.cached_values
      expect(results.size).to eq(1)
      expect(results.keys[0]).to eq("Joe User+researched number 1")
    end

    it "filters by value" do
      Card::Env.params["value"] = "none"
      results = all_values.cached_values
      metrics.each do |metric|
        expect(results.keys).not_to include(metric.name)
      end
      all_metrics = Card.search type_id: Card::MetricID
      all_metrics.each do |m|
        next if metrics.include?(m)
        expect(results.keys).to include(m.name)
      end
    end

    it "filters by type" do
      Card::Env.params["type"] = ["wikirating"]
      results = all_values.cached_values
      expect(results.size).to eq(1)
      expect(results.keys[0]).to eq("Jedi+darkness rating")
    end
  end
end
