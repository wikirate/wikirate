
require_relative "../../support/value_type_shared_examples"

RSpec.describe Card::Set::Type::MetricValue do
  let(:answer) { sample_metric_value }
  let(:metric) { sample_metric }
  let(:company) { sample_company }

  describe "getting related cards" do
    it "returns correct year" do
      expect(answer.year).to eq("1977")
    end
    it "returns correct metric name" do
      expect(answer.metric).to eq("Jedi+Sith Lord in Charge")
    end
    it "returns correct company name" do
      expect(answer.company_name).to eq("Death Star")
    end
    it "returns correct company card" do
      expect(answer.company_card.name).to eq("Death Star")
    end
    it "returns correct metric card" do
      expect(answer.metric_card.name).to eq("Jedi+Sith Lord in Charge")
    end
  end

  describe "views" do
    specify "modal_details" do
      url = "/#{answer.name.url_key}?layout=modal&"\
            "slot%5Boptional_horizontal_menu%5D=hide&slot%5Bshow%5D=menu"
      html = answer.format.render_modal_details
      expect(html).to have_tag("span.metric-value") do
        with_tag "a", text: "Darth Sidious", with: { href: url }
      end
    end

    specify "concise" do
      html = answer.format.render_concise
      expect(html).to have_tag("span.metric-year", text: /1977 =/)
      expect(html).to have_tag("span.metric-value")
      expect(html).to have_tag("span.metric-unit",
                               text: /Imperial military units/)
    end
  end

  context "value type is Number" do
    include_examples "create answer", :number, "33", "invalid"

    context "unknown value" do
      subject { create_answer(content: "unknown").format.render_modal_details }

      it "shows unknown instead of 0 in modal_details" do
        is_expected.to have_tag("a", text: "unknown")
      end
    end
  end

  context "value type is Money" do
    include_examples "create answer", :money, "33", "invalid"

    describe "view :concise" do
      subject { sample_answer(:money).format.render_concise }

      it "shows currency sign" do
        is_expected.to have_tag "span.metric-unit" do
          with_text " $ "
        end
      end

      it "shows year" do
        is_expected.to have_tag "span.metric-year" do
          with_text "1977 = "
        end
      end

      it "shows value" do
        is_expected.to have_tag "span.metric-value" do
          with_text "200"
        end
      end
    end
  end

  context "value type is Category" do
    include_examples "create answer", :category, "yes", "invalid"
  end

  context "value type is Free Text" do
    let(:source) { sample_source }
    let(:new_answer) do
      create_answer content: "hoi polloi", year: "2015", source: source.name
    end

    include_examples "create answer", :free_text, "yes", nil

    example "year can be changed" do
      expect(new_answer.name)
        .to eq "#{metric.name}+#{company.name}+2015"
      new_name = "#{metric.name}+#{company.name}+2014"
      new_answer.update_attributes! name: new_name
      expect(new_answer.name).to eq(new_name)
    end

    it "updates value correctly" do
      answer.update_attributes! subfields: { value: "updated value" }
      expect(Card[answer, :value].content).to eq("updated value")
    end

    describe "+source" do
      let(:source_card) { new_answer.fetch trait: :source }

      it "includes source in +source" do
        expect(source_card.item_names).to include(source.name)
      end

      it "updates source's company" do
        new_answer
        source_company = source.fetch trait: :wikirate_company
        expect(source_company.item_cards).to include(company)
      end

      it "updates source's report type" do
        new_answer
        source_report_type = source.fetch trait: :report_type
        expect(source_report_type.item_names)
          .to include("Conflict Mineral Report")
      end

      it "fails with a non-existing source" do
        expect(build_answer(source: "Page-1"))
          .to be_invalid.because_of(source: include("does not exist"))
      end

      it "fails if source card cannot be created" do
        expect(build_answer(source: nil))
          .to be_invalid.because_of(source: include("does not exist"))
      end
    end
  end
end
