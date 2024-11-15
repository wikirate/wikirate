RSpec.describe Card::Set::Type::Record do
  let(:record) { sample_record }
  let(:metric) { sample_metric }
  let(:company) { sample_company }

  describe "getting related cards" do
    it "returns correct year" do
      expect(record.year).to eq("1977")
    end
    it "returns correct metric name" do
      expect(record.metric).to eq("Jedi+Sith Lord in Charge")
    end
    it "returns correct company name" do
      expect(record.company_name).to eq("Death Star")
    end
    it "returns correct company card" do
      expect(record.company_card.name).to eq("Death Star")
    end
    it "returns correct metric card" do
      expect(record.metric_card.name).to eq("Jedi+Sith Lord in Charge")
    end
  end

  describe "views" do
    specify "concise" do
      html = record.format.render_concise
      expect(html).to have_tag(".TYPE-year", text: /1977/)
      expect(html).to have_tag("span.metric-value")
      expect(html).to have_tag("span.metric-legend", text: /Imperial military units/)
    end
  end

  context "when value type is Money" do
    include_examples "create record", :money, "33", "invalid"

    describe "view :concise" do
      subject { sample_record(:money).format.render_concise }

      it "shows currency sign" do
        is_expected.to have_tag "span.metric-legend" do
          with_text /USD/
        end
      end

      it "shows year" do
        is_expected.to have_tag ".TYPE-year" do
          with_text /1977/
        end
      end

      it "shows value" do
        is_expected.to have_tag "span.metric-value" do
          with_text "200"
        end
      end
    end
  end

  context "when value type is Category" do
    include_examples "create record", :category, "yes", "invalid"
  end

  context "when value type is Free Text" do
    let(:source) { sample_source }
    let(:new_record) do
      create_record value: "1234", year: "2015", source: source.name
    end

    include_examples "create record", :free_text, "yes", nil

    example "year can be changed" do
      expect(new_record.name)
        .to eq "#{metric.name}+#{company.name}+2015"
      new_name = "#{metric.name}+#{company.name}+2014"
      newer_record = new_record.refresh true
      # FIXME: this refresh prevents a log error
      # (exception in integrate phase: undefined method `metric_card`)
      # that error is happening because the director on new_record is not getting cleared.
      newer_record.update! name: new_name
      expect(newer_record.name).to eq(new_name)
    end

    it "updates value correctly" do
      record.update! fields: { value: "updated value" }
      expect(Card[record, :value].content).to eq("updated value")
    end
  end

  describe "event: auto_add_company" do
    let(:new_company) { "Kuhl Co" }

    it "adds company when triggered" do
      Card.create record_args.merge("+company" => new_company,
                                    trigger: :auto_add_company)
      expect(Card[new_company].type_id).to eq(Card::CompanyID)
    end

    it "fails when not triggered with unknown company" do
      expect(create_record(company: new_company).errors[:company])
        .to include(/valid company required/)
    end
  end
end
