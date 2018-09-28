RSpec.describe Card::Metric do
  let :formula_metric do
    researched_metrics
    described_class.create name: "Jedi+friendliness",
                           type: :formula,
                           formula: "1/{{Jedi+darksidiness}}"
  end

  let :score_metrics do
    researched_metrics
    described_class.create name: "Jedi+strength in the Force+Joe Camel",
                           type: :score,
                           formula: { yes: 10, no: 0 }
    described_class.create name: "Jedi+darksidiness+Joe User",
                           type: :score,
                           formula: "{{Jedi+darksidiness}}/10"
    described_class.create name: "Jedi+darksidiness+Joe Camel",
                           type: :score,
                           formula: "{{Jedi+darksidiness}}/20"
  end

  let :researched_metrics do
    Card::Env[:protocol] = "http://"
    Card::Env[:host] = "wikirate.org"
    source = create_page url: "http://wikiwand.com/en/Death_Star"
    described_class.create name: "Jedi+strength in the Force",
                           value_type: "Category",
                           value_options: %w[yes no] do
      Death_Star "1977" => { value: "yes",
                             source: "[[#{source.name}]]" }
    end
    source = create_page url: "http://wikiwand.com/en/Return_of_the_Jedi"
    described_class.create name: "Jedi+darksidiness" do
      Death_Star "1977" => { value: 100, source: "[[#{source.name}]]" }
    end
  end

  let :wikirate_rating_metric do
    score_metrics
    described_class.create(
      name: "Jedi+darkness rating",
      type: :wiki_rating,
      formula: "({{Jedi+darksidiness+Joe User}}+" \
               "{{Jedi+strength in the Force+Joe Camel}})/2"
    )
  end

  describe "#create" do
    let(:metric) { Card["MD+MT"] }
    let(:value) { metric.field("SPECTRE").field("2000") }
    let(:source_link) do
      Card["MD+MT+Death Star+2000+source"].item_cards.first.field("link")
    end

    def create_metric
      Card::Auth.as_bot do
        source = create_page url: "http://example.com"
        described_class.create name: "MD+MT", type: :formula,
                               formula: "1", random_source: true do
          SPECTRE 2000 => 50, 2001 => 100
          Death_Star 2000 => { value: 50, source: "[[#{source.name}]]" }
        end
      end
    end

    it "small API test" do
      create_metric

      expect(metric).to be_truthy
      expect(metric.type_id).to eq Card::MetricID
      expect(metric.field(:formula).content).to eq "1"
      expect(metric.metric_type).to eq "Formula"

      expect(value).to be_truthy
      expect(value.type_id).to eq Card::MetricAnswerID
      expect(value.field("value").content).to eq "50"
      expect(Card["MD+MT+SPECTRE+2001+value"].content).to eq "100"

      expect(source_link.content).to eq("http://example.com")
      expect(Card["MD+MT+Death Star+2000+value"].content).to eq "50"
    end

    it "creates value options" do
      Card::Auth.as_bot do
        researched_metrics
      end
      expect(Card["Jedi+strength in the Force+value type"].content)
        .to eq "[[Category]]"
      expect(Card["Jedi+strength in the Force+value options"].content)
        .to eq %w[yes no].to_pointer_content
    end

    it "creates score" do
      Card::Auth.as_bot do
        # create a new research metric so that it could create a score metric
        # based on a categorical metric as we are now checking if all value
        # options are filled with a score
        researched_metrics
        described_class.create name: "Jedi+strength in the Force+Joe Camel",
                               type: :score,
                               formula: { yes: 10, no: 0 }
      end
    end

    def create_relationship_metric
      Card::Auth.as_bot do
        described_class.create name: "Jedi+owns",
                               type: :relationship,
                               inverse_title: "owned by",
                               random_source: true do
          SPECTRE 2000 => { "Los Pollos Hermanos" => "10",
                            "Death_Star" => "5" }
        end
      end
    end

    it "creates relationship metric" do
      create_relationship_metric

      expect(Card["Jedi+owns"].type_id)
        .to eq Card::MetricID
      expect(Card["Jedi+owns+SPECTRE+2000"].type_name)
        .to eq "Answer"
      expect(Card["Jedi+owns+SPECTRE+2000+Los Pollos Hermanos"].type_name)
        .to eq "Relationship Answer"
      expect(Card["Jedi+owns+SPECTRE+2000+Los Pollos Hermanos+value"].content)
        .to eq "10"
      expect(Card["Jedi+owns+SPECTRE+2000+Death Star+value"].content)
        .to eq "5"
    end
  end

  describe "Card#new" do
    it "recognizes metric type" do
      metric = Card.new name: "MT+MD", type_id: Card::MetricID,
                        "+*metric type" => "[[Researched]]"
      expect(metric.set_format_modules(Card::Format::HtmlFormat))
        .to include(Card::Set::MetricType::Researched::HtmlFormat)
    end
  end
end
