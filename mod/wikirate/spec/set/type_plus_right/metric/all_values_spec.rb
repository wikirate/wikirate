describe Card::Set::TypePlusRight::Metric::AllValues do
  let(:all_values) { @metric.fetch trait: :all_values }
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

  describe '#get_params' do
    it "returns value from params" do
      Card::Env.params["offset"] = "5"
      expect(all_values.get_params("offset", 0)).to eq(5)
    end

    it "returns default" do
      expect(all_values.get_params("offset", 0)).to eq(0)
    end
  end

  describe '#get_cached_values' do
    it "returns correct cached metric values" do
      results = all_values.get_cached_values
      value_idx = 1
      @companies.each do |company|
        expect(results.key?(company.name)).to be_truthy
        0.upto(3) do |i|
          expected_result = { year: (2015 - i).to_s,
                              value: (value_idx * 5 + i).to_s }
          expect(results[company.name]).to include(expected_result)
        end
        value_idx += 1
      end
    end
    context "delete a value" do
      it "removes deleted cached value" do
        Card::Auth.as_bot do
          Card["#{@metric.name}+Apple Inc.+2015"].delete
        end
        results = all_values.get_cached_values
        not_expected_result = {
          year: "2015", value: "20"
        }
        expect(results["Apple Inc."]).not_to include(not_expected_result)
      end
    end
    context "update a value" do
      it "updates cached value" do
        card = Card["#{@metric.name}+Apple Inc.+2015+value"]
        card.content = 25
        card.save!
        results = all_values.get_cached_values
        expected_result = {
          year: "2015", value: "25"
        }
        expect(results["Apple Inc."]).to include(expected_result)
      end
    end
    context "rename a value" do
      it "updates cached value" do
        card = Card["#{@metric.name}+Apple Inc.+2015+value"]
        card.name = "#{@metric.name}+Death Star+2000+value"
        card.save!
        results = all_values.get_cached_values
        expected_result = {
          year: "2000", value: "20"
        }
        expect(results["Death Star"]).to include(expected_result)
        expect(results["Apple Inc."]).not_to include(expected_result)
      end
    end
    context "rename a metric value" do
      it "updates cached value" do
        card = Card["#{@metric.name}+Apple Inc.+2015"]
        card.name = "#{@metric.name}+Death Star+2000"
        card.save!
        results = all_values.get_cached_values
        expected_result = {
          year: "2000", value: "20"
        }
        expect(results["Death Star"]).to include(expected_result)
        expect(results["Apple Inc."]).not_to include(expected_result)
      end
    end
  end

  describe '#count' do
    it "returns correct cached count" do
      result = all_values.count {}
      expect(result).to eq(4)
    end
  end
  describe '#num?' do
    context "Numeric type" do
      it "returns true" do
        @metric.update_attributes! subcards: { "+value_type" => "[[Number]]" }
        format = all_values.format
        expect(format.num?).to be true
        @metric.update_attributes! subcards: { "+value_type" => "[[Money]]" }
        expect(format.num?).to be true
      end
    end
    context "Other type" do
      it "return false" do
        metric = Card.create! type_id: Card::MetricID, name: "Totoro+Chinchilla"
        metric.update_attributes! subcards: { "+value_type" => "[[Category]]" }
        all_values = metric.fetch trait: :all_values
        format = all_values.format
        expect(format.num?).to be false
        metric.update_attributes! subcards: { "+value_type" => "[[Free Text]]" }
        expect(format.num?).to be false
      end
    end
  end
  describe '#sorted_result' do
    before do
      @cached_result = all_values.cached_values
      @format = all_values.format
    end
    it "sorts by company name asc" do
      results = @format.sorted_result(
        "name", "asc", false
      )
      expect(results.map { |x| x[0] }).to eq(
        ["Amazon.com, Inc.",
         "Apple Inc.",
         "Death Star",
         "Sony Corporation"
        ]
      )
    end
    it "sorts by company name desc" do
      results = @format.sorted_result(
        "name", "desc", false
      )
      expect(results.map { |x| x[0] }).to eq(
        ["Sony Corporation",
         "Death Star",
         "Apple Inc.",
         "Amazon.com, Inc."
        ]
      )
    end

    it "sorts by value asc" do
      results = @format.sorted_result "value", "asc"
      expect(results.map { |x| x[0] }).to eq(
        ["Death Star",
         "Sony Corporation",
         "Amazon.com, Inc.",
         "Apple Inc."
        ]
      )
    end

    it "sorts by value desc" do
      results = @format.sorted_result "value", "desc"
      expect(results.map { |x| x[0] }).to eq(
        ["Apple Inc.",
         "Amazon.com, Inc.",
         "Sony Corporation",
         "Death Star"
        ]
      )
    end
  end

  describe "view" do
    it "renders card_list_header" do
      Card::Env.params["offset"] = "0"
      Card::Env.params["limit"] = "20"
      html = all_values.format.render_card_list_header
      url_key = all_values.cardname.url_key
      expect(html).to have_tag("div",
                               with: { class: "yinyang-row column-header" }) do
        with_tag :div, with: { class: "company-item value-item" } do
          with_tag :a, with: {
            class: "header metric-list-header slotter",
            href: "/#{url_key}?limit=20&offset=0"\
                                      "&sort_by=name"\
                                      "&sort_order=asc&view=content"

          }
          with_tag :a, with: {
            class: "data metric-list-header slotter",
            href: "/#{url_key}?limit=20&offset=0"\
                                      "&sort_by=value&sort_order=asc"\
                                      "&view=content"
          }
        end
      end
    end
  end
end
