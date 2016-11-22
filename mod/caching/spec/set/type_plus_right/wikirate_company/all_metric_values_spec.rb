describe Card::Set::TypePlusRight::WikirateCompany::AllMetricValues do
  let(:all_metric_values) { Card["Samsung"].fetch trait: :all_metric_values }
  let(:create_card) { Card.create name: "a card" }
  it "updates if value is created in event" do
    expect(all_metric_values.values_by_name.keys.sort)
      .to eq ["Joe User+researched number 3", "Joe User+researched number 2",
              "Joe User+researched number 1"].sort
    Card::Auth.as_bot do
      in_stage :prepare_to_store,
               on: :save, for: "a card",
               trigger: -> { create_card } do
        Card["Jedi+deadliness"].create_value company: "Samsung",
                                             year: "2010",
                                             value: "100",
                                             source: get_a_sample_source
      end
    end
    av = Card.fetch("Samsung").all_metric_values_card.values_by_name
    expect(av.keys).to include("Jedi+deadliness")
    update_time = Card["Jedi+deadliness+Samsung+2010+value"].updated_at.to_i
    expect(av["Jedi+deadliness"])
      .to include("value" => "100", "year" => "2010",
                  "last_update_time" => update_time)
  end

  describe "#item_cards" do
    it "finds all metric answers with values" do
      expect(all_metric_values.item_cards.size).to eq 6
    end
  end

  describe "#values_by_name" do
    let(:company_name) { "new company" }
    let(:metric_name) { "Jedi+Sith Lord in Charge" }
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
    before do
      metrics.each.with_index do |metric, value_idx|
        0.upto(3) do |i|
          metric.create_value company: company.name,
                              value: (value_idx + 1) * 5 + i,
                              year: 2015 - i,
                              source: get_a_sample_source.name
        end
      end
    end

    subject { company.all_metric_values_card.values_by_name }
    def any_value? company, year, value, values=subject
      values[company].any? do |row|
        row[:year] == year && row[:value] == value
      end
    end
    it "has correct metric values" do
      value_idx = 1
      metrics.each do |metric|
        expect(subject.key?(metric.name)).to be_truthy
        0.upto(3) do |i|
          found_expected = any_value? metric.name,
                                      (2015 - i).to_s,
                                      (value_idx * 5 + i).to_s
          expect(found_expected).to be_truthy
        end
        value_idx += 1
      end
    end

    context "delete a value" do
      it "removes deleted cached value" do
        metric_name = "Jedi+Sith Lord in Charge"
        delete "#{metric_name}+#{company_name}+2015"
        expect(any_value?(metric_name, "2015", "20")).to be_falsey
      end
    end
    context "update a value" do
      it "updates cached value" do
        update "#{metric_name}+#{company_name}+2015+value",
               content: 25
        expect(any_value?(metric_name, "2015", "25")).to be_truthy
      end
    end
    context "rename a metric answer" do
      it "updates cached value" do
        update "#{metric_name}+#{company_name}+2015",
               name: "#{metric_name}+Death Star+2000"
        new_values = Card["Death Star"].all_metric_values_card.values_by_name
        expect(any_value?(metric_name, "2000", "5", new_values)).to be_truthy
        expect(any_value?(metric_name, "2015", "5")).to be_falsey
      end
    end
    context "rename metric in a metric answer" do
      it "updates cached value" do
        update "#{metric_name}+#{company_name}+2015",
               name: "Jedi+deadliness+#{company_name}+2000"
        expect(any_value?("Jedi+deadliness", "2000", "5")).to be_truthy
        expect(any_value?(metric_name, "2015", "5")).to be_falsey
      end
    end
    context "rename company using name variant in a metric answer" do
      it "updates cached value" do
        update "#{metric_name}+#{company_name}+2015",
               name: "#{metric_name}+death_star+2000"
        new_values = Card["Death Star"].all_metric_values_card.values_by_name
        expect(any_value?(metric_name, "2000", "5", new_values)).to be_truthy
        expect(any_value?(metric_name, "2015", "5")).to be_falsey
      end
    end
  end
end
