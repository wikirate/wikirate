describe Card::Set::TypePlusRight::Metric::AllValues, "metric value caching" do
  let(:all_values) { Card["Jedi+deadliness"].fetch trait: :all_values }
  let(:create_card) { Card.create name: "a card" }
  it "gets updated if value is created in event" do
    $first = true
    expect(all_values.values_by_name.keys).to eq ["Death_Star"]
    Card::Auth.as_bot do
      in_stage :prepare_to_store,
               on: :save,
               trigger: -> { create_card } do
        return unless $first
        $first = false
        Card["Jedi+deadliness"].create_value company: "Samsung",
                                             year: "2010",
                                             value: "100",
                                             source: get_a_sample_source
      end
    end

    av = Card.fetch("Jedi+deadliness+all values").values_by_name
    expect(av["Samsung"])
      .to include(value: "100", year: "2010")
  end

  describe "#get_cached_values" do
    it "returns correct cached metric values" do
      results = all_values.values_by_name
      value_idx = 1
      @companies.each do |company|
        expect(results.key?(company.name)).to be_truthy

        0.upto(3) do |i|
          found_expected = results[company.name].any? do |row|
            row[:year] == (2015 - i).to_s &&
              row[:value] == (value_idx * 5 + i).to_s
          end
          expect(found_expected).to be_truthy
        end
        value_idx += 1
      end
    end
    context "delete a value" do
      it "removes deleted cached value" do
        Card::Auth.as_bot do
          Card["#{@metric.name}+Apple Inc.+2015"].delete
        end
        results = all_values.values_by_name
        found_unexpected = results["Apple Inc."].any? do |row|
          row[:year] == "2015" && row[:value] == "20"
        end
        expect(found_unexpected).to be_falsey
      end
    end
    context "update a value" do
      it "updates cached value" do
        card = Card["#{@metric.name}+Apple Inc.+2015+value"]
        card.content = 25
        card.save!
        results = all_values.values_by_name
        found_expected = results["Apple Inc."].any? do |row|
          row[:year] == "2015" && row[:value] == "25"
        end
        expect(found_expected).to be_truthy
      end
    end
    context "rename a value" do
      it "updates cached value" do
        card = Card["#{@metric.name}+Apple Inc.+2015+value"]
        card.name = "#{@metric.name}+Death Star+2000+value"
        card.save!
        results = all_values.values_by_name
        found_expected = results["Death Star"].any? do |row|
          row[:year] == "2000" && row[:value] == "20"
        end
        expect(found_expected).to be_truthy
        found_unexpected = results["Apple Inc."].any? do |row|
          row[:year] == "2000" && row[:value] == "20"
        end
        expect(found_unexpected).to be_falsey
      end
    end
    context "rename a metric value" do
      it "updates cached value" do
        card = Card["#{@metric.name}+Apple Inc.+2015"]
        card.name = "#{@metric.name}+Death Star+2000"
        card.save!
        results = all_values.values_by_name
        found_expected = results["Death Star"].any? do |row|
          row[:year] == "2000" && row[:value] == "20"
        end
        expect(found_expected).to be_truthy
        found_unexpected = results["Apple Inc."].any? do |row|
          row[:year] == "2000" && row[:value] == "20"
        end
        expect(found_unexpected).to be_falsey
      end
    end
  end
end
