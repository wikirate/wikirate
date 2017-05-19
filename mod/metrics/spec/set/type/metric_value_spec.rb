
require_relative "../../support/value_type_shared_examples"

describe Card::Set::Type::MetricValue do
  def metric_value metric, content="content"
    create_answer(metric: metric,  content: content)
  end

  let(:metric) { sample_metric }
  let(:company) { sample_company }

  describe "#metric" do
    it "returns metric name" do
      expect(create_answer(metric: metric).metric_name)
        .to eq metric.name
    end
  end

  context "value type is Number" do
    it_behaves_like "value_type", :number, "33", "hello"

    context "unknown value" do
      it "shows unknown instead of 0 in modal_details" do
        html = create_answer(content: "unknown").format.render_modal_details
        expect(html).to have_tag("a", text: "unknown")
      end
    end
  end

  context "value type is Money" do
    let(:metric) { sample_metric :money }

    it_behaves_like "value_type", :money, "33", "hello"

    describe "view :concise" do
      subject do
        create_answer(metric: metric, content: "33").format.render_concise
      end

      it "shows currency sign" do
        is_expected.to have_tag "span.metric-unit" do
          with_text " $ "
        end
      end

      it "shows year" do
        is_expected.to have_tag "span.metric-year" do
          with_text "2015 = "
        end
      end

      it "shows value" do
        is_expected.to have_tag "span.metric-value" do
          with_text "33"
        end
      end
    end
  end

  context "value type is category" do
    it_behaves_like "value_type", :category, "yes", "hello"
  end

  context "value type is free text" do
    let(:source) { sample_source }

    let(:metric_value) do
      create_answer metric: metric, company: company,
                    content: "hoi polloi", year: "2015",
                    source: source.name
    end

    describe "getting related cards" do
      it "returns correct year" do
        expect(metric_value.year).to eq("2015")
      end
      it "returns correct metric name" do
        expect(metric_value.metric).to eq(metric.name)
      end
      it "returns correct company name" do
        expect(metric_value.company_name).to eq(company.name)
      end
      it "returns correct company card" do
        expect(metric_value.company_card.id).to eq(company.id)
      end
      it "returns correct metric card" do
        expect(metric_value.metric_card.id).to eq(metric.id)
      end
    end

    it "gets correct autoname" do
      name = "#{metric.name}+#{company.name}+2015"
      expect(metric_value.name).to eq(name)
    end

    it "saving correct value" do
      value_card = Card["#{metric_value.name}+value"]
      expect(value_card.content).to eq("hoi polloi")
    end

    context "update metric value name" do
      it "succeeds" do
        new_name = "#{metric.name}+#{company.name}+2014"
        metric_value.update_attributes! name: new_name
        expect(metric_value.name).to eq(new_name)
      end
    end

    describe "+source" do
      let(:source_card) { metric_value.fetch trait: :source }

      it "includes source in +source" do
        expect(source_card.item_names).to include(source.name)
      end

      it "updates source's company" do
        source_company = source.fetch trait: :wikirate_company
        expect(source_company.item_cards).to include(company)
      end

      it "updates source's report type" do
        source_report_type = source.fetch trait: :report_type
        expect(source_report_type.item_names)
          .to include("Conflict Mineral Report")
      end

      it "fails with a non-existing source" do
        expect(new_answer source: "Page-1")
          .to be_invalid.because_of(source: match(/does not exist/))
      end

      it "fails if source card cannot be created" do
        expect(new_answer source: nil)
          .to be_invalid.because_of(source: match(/does not exist/))
      end
    end

    it "updates value correctly" do
      quote = "if nobody hates you, you're doing something wrong."
      metric_value.update_attributes! subcards: { "+value" => quote }
      expect(Card[metric_value, :value].content).to eq(quote)
    end

    describe "views" do
      specify "timeline_data" do
        expect(metric_value.format.render_timeline_data)
          .to have_tag("div", with: { class: "timeline-row" }) do
            with_tag("div", with: { class: "timeline-dot" })
            with_tag("div", with: { class: "td year" }) do
              with_tag("span", text: "2015")
            end
            with_tag("div", with: { class: "td value" }) do
              with_tag("span", with: { class: "metric-value" }) do
                with_tag("a", text: "hoi polloi")
              end
              with_tag("span", with: { class: "metric-unit" },
                               text: /Imperial military units/)
            end
          end
      end

      specify "modal_details" do
        url = "/#{metric_value.cardname.url_key}?layout=modal&"\
              "slot%5Boptional_horizontal_menu%5D=hide&slot%5Bshow%5D=menu"
        html = metric_value.format.render_modal_details
        expect(html).to have_tag("span.metric-value") do
          with_tag "a", with: { href: url }, text: "hoi polloi"
        end
      end

      specify "concise" do
        html = metric_value.format.render_concise

        expect(html).to have_tag("span.metric-year", text: /2015 =/)
        expect(html).to have_tag("span.metric-value")
        expect(html).to have_tag("span.metric-unit",
                                         text: /Imperial military units/)
      end
    end
  end
end
