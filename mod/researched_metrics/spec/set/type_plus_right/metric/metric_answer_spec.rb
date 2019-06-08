RSpec.describe Card::Set::TypePlusRight::Metric::MetricAnswer do
  let(:metric) { Card[@metric_name || "Jedi+disturbances in the Force"] }
  let(:metric_answer) { metric.fetch trait: :metric_answer }

  # @return [Array] of company+year strings
  let :answer_items do
    metric_answer.item_cards.map { |c| c.name.parts[2..3].join "+" }
  end

  def with_latest_filter_params
    Card::Env[:filter] = { year: :latest }
  end

  context "when no filter in params" do
    specify "#item_cards returns answers from multiple years and companies" do
      expect(answer_items)
        .to include("Death_Star+1977", "Death_Star+2000", "Monster_Inc+2000")
    end

    specify "#count counts all" do
      expect(metric_answer.count).to eq(Answer.where(metric_id: metric.id).count)
    end
  end

  context "when year=latest is set in params" do
    # This is current behavior, but I'd prefer that params only affect queries in formats.
    specify "#item_cards returns only latest answers" do
      with_latest_filter_params do
        expect(answer_items).to eq(%w[Death_Star+2001
                                      Monster_Inc+2000
                                      Slate_Rock_and_Gravel_Company+2005
                                      SPECTRE+2000])
      end
    end

    specify "#count counts only latest years" do
      with_latest_filter_params do
        expect(metric_answer.count)
          .to eq(Answer.where(metric_id: metric.id, latest: true).count)
      end
    end
  end

  describe ":table view" do
    context "when metric researched" do
      subject { metric_answer.format._render_table }

      it "has a bootstrap table" do
        is_expected.to have_tag "table" do
          with_tag :tr, with: {
            "data-row-card": {
              url_key: "Jedi+disturbances_in_the_Force+Death_Star+2001",
              known: true
            }.to_json
          }
        end
      end
    end

    context "when metric calculated" do
      subject do
        @metric_name = "Jedi+friendliness"
        metric_answer.format._render_table
      end

      example "formula metric" do
        is_expected.to have_tag "table" do
          with_tag :tr, with: {
            "data-row-card" => { url_key: "Jedi+friendliness+Death_Star+1977",
                                 known: true }.to_json }
        end
      end
    end

    describe ":core view" do
      subject { metric_answer.format._render_filtered_content }

      it "has filter widget" do
        is_expected.to have_tag ".card" do
          with_tag "._filter-widget"
        end
      end
      it "has chart" do
        is_expected.to have_tag ".row" do
          with_tag ".vis"
        end
      end
      it "has counts" do
        is_expected.to have_tag "table.filtered-answer-counts" do
          with_tag "span.known.badge", "4"
        end
      end
      it "has table" do
        is_expected.to have_tag "table" do
          with_text(/Death Star\s*yes\s*yes, no\s*2001/)
        end
      end
    end
  end
end
