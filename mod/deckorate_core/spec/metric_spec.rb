# This is really a test of the MetricCreator and AnswerCreator APIs

RSpec.describe Metric do
  let :researched_metrics do
    sample_source_name = sample_source.name
    create_metric name: "Jedi+strength in the Force",
                  value_type: "Category",
                  value_options: %w[yes no] do
      Death_Star "1977" => { value: "yes",
                             source: sample_source_name }
    end
    create_metric name: "Jedi+darksidiness" do
      Death_Star "1977" => { value: 100, source: sample_source_name }
    end
  end

  describe "#create" do
    let(:metric) { Card["MD+MT"] }
    let(:value) { metric.fetch("SPECTRE").fetch("2000") }
    let(:source_link) do
      Card["MD+MT+Death Star+2000+source"].first_card.fetch("link")
    end

    def create_test_metric
      Card::Auth.as_bot do
        source = create_source "http://example.com"
        create_metric name: "MD+MT", type: :researched, test_source: true do
          SPECTRE 2000 => 50, 2001 => 100
          Death_Star 2000 => { value: 50, source: "[[#{source.name}]]" }
        end
      end
    end

    xit "small API test", as_bot: true do
      create_test_metric

      expect(metric).to be_truthy
      expect(metric.type_id).to eq Card::MetricID
      expect(metric.metric_type).to eq "Researched"

      expect(value).to be_truthy
      expect(value.type_id).to eq Card::AnswerID
      expect(value.fetch("value").content).to eq "50"
      expect(Card["MD+MT+SPECTRE+2001+value"].content).to eq "100"

      expect(source_link.content).to eq("http://example.com")
      expect(Card["MD+MT+Death Star+2000+value"].content).to eq "50"
    end

    it "creates value options" do
      Card::Auth.as_bot do
        researched_metrics
      end
      expect(Card["Jedi+strength in the Force+value type"].content)
        .to eq "Category"
      expect(Card["Jedi+strength in the Force+value options"].content)
        .to eq %w[yes no].to_pointer_content
    end

    it "creates score" do
      Card::Auth.as_bot do
        # create a new research metric so that it could create a score metric
        # based on a categorical metric as we are now checking if all value
        # options are filled with a score
        researched_metrics
        create_metric name: "Jedi+strength in the Force+Joe Camel",
                      type: :score,
                      rubric: { yes: 10, no: 0 }.to_json
      end
    end

    def create_relation_metric
      Card::Auth.as_bot do
        create_metric name: "Jedi+owns",
                      type: :relation,
                      inverse_title: "owned by",
                      test_source: true do
          SPECTRE 2000 => { "Los Pollos Hermanos" => "10",
                            "Death_Star" => "5" }
        end
      end
    end

    it "creates relation metric" do
      create_relation_metric

      expect(Card["Jedi+owns"].type_id)
        .to eq Card::MetricID
      expect(Card["Jedi+owns+SPECTRE+2000"].type_code)
        .to eq :answer
      expect(Card["Jedi+owns+SPECTRE+2000+Los Pollos Hermanos"].type_name)
        .to eq "Relationship"
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
