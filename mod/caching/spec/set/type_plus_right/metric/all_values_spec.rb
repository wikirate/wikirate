describe Card::Set::TypePlusRight::Metric::AllValues, "metric value caching" do
  let(:all_values) { Card["Jedi+deadliness"].fetch trait: :all_values }
  let(:create_card) { Card.create name: "a card" }
  it "updates if value is created in event" do
    $first = true
    expect(all_values.values_by_name.keys).to eq ["Death Star"]
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
    av = Card.fetch("Jedi+deadliness").all_values_card.values_by_name
    expect(av.keys).to include("Samsung")
    update_time = Card["Jedi+deadliness+Samsung+2010+value"].updated_at.to_i
    expect(av["Samsung"])
      .to include("value" => "100", "year" => "2010",
                  "last_update_time" => update_time)
  end

  describe "#values_by_name" do
    before do
      @metric = get_a_sample_metric
      @companies = [
        Card["Death Star"],
        Card["Sony Corporation"],
        Card["Amazon.com, Inc."],
        Card["Apple Inc."]
      ]
      @companies.each.with_index do |company, value_idx|
        0.upto(3) do |i|
          @metric.create_value company: company.name,
                               value: (value_idx + 1) * 5 + i,
                               year: 2015 - i,
                               source: get_a_sample_source.name
        end
      end
    end

    subject { @metric.all_values_card.values_by_name }
    it "has correct metric values" do
      value_idx = 1
      @companies.each do |company|
        expect(subject.key?(company.name)).to be_truthy

        0.upto(3) do |i|
          found_expected = subject[company.name].any? do |row|
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
        delete "#{@metric.name}+Apple Inc.+2015"
        found_unexpected = subject["Apple Inc."].any? do |row|
          row[:year] == "2015" && row[:value] == "20"
        end
        expect(found_unexpected).to be_falsey
      end
    end
    context "update a value" do
      it "updates cached value" do
        update "#{@metric.name}+Apple Inc.+2015+value", content: 25
        found_expected = subject["Apple Inc."].any? do |row|
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
