RSpec.describe Card::Set::TypePlusRight::Metric::MetricAnswer do
  it_behaves_like "cached count", "Jedi+disturbances in the force+answer", 11, 1 do
    let :add_one do
      Card["Jedi+disturbances in the force"].create_answers true do
        Samsung "1977" => "yes"
      end
    end
    let :delete_one do
      Card["Jedi+disturbances in the force+Death Star+1990"].delete
    end
  end

  let(:metric) { Card[@metric_name || "Jedi+disturbances in the Force"] }
  let(:metric_answer) { metric.fetch :metric_answer }

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
        .to include("Death Star+1977", "Death Star+2000", "Monster Inc+2000")
    end

    specify "#count counts all" do
      expect(metric_answer.count).to eq(Answer.where(metric_id: metric.id).count)
    end
  end

  context "when year=latest is set in params" do
    # This is current behavior, but I'd prefer that params only affect queries in formats.
    specify "#item_cards returns only latest answers" do
      with_latest_filter_params do
        expect(answer_items).to eq(["Death Star+2001",
                                    "Monster Inc+2000",
                                    "Slate Rock and Gravel Company+2005",
                                    "SPECTRE+2000"])
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
    def with_answer_row
      with_tag :tr, with: { "data-details-mark": answer_name } do
        with_tag :td, class: "header"
        with_tag :td, class: "data"
      end
    end

    context "when metric researched" do
      subject { metric_answer.format._render_table }

      let(:answer_name) { "#{metric.name.url_key}+Death_Star+2001" }

      example "research_metric table" do
        is_expected.to have_tag "table" do
          with_answer_row
        end
      end
    end

    context "when metric calculated" do
      subject do
        @metric_name = "Jedi+friendliness"
        metric_answer.format._render_table
      end

      let(:answer_name) { "#{metric.name.url_key}+Death_Star+1977" }

      example "formula metric table" do
        is_expected.to have_tag "table" do
          with_answer_row
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
        is_expected.to have_tag ".answer-search-chart" do
          with_tag ".vis"
        end
      end
      it "has progress_bar" do
        is_expected.to have_tag "div.answer-search-progress" do
          with_tag "div.progress-known", "11 Known"
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
