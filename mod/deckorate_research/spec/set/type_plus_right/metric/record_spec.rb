RSpec.describe Card::Set::TypePlusRight::Metric::Record do
  it_behaves_like "cached count", ["Jedi+disturbances in the force", :record], 12, 1 do
    let :add_one do
      create_records "Jedi+disturbances in the force", true do
        Samsung "1977" => "yes"
      end
    end
    let :delete_one do
      Card["Jedi+disturbances in the force+Death Star+1990"].delete
    end
  end

  let(:metric_name)   { "Jedi+disturbances in the Force" }
  let(:metric)        { metric_name.card }
  let(:record) { metric.fetch :record }

  # @return [Array] of company+year strings
  let :record_items do
    record.item_cards.map { |c| c.name.parts[2..3].join "+" }
  end

  def with_latest_filter_params
    Card::Env.params[:filter] = { year: :latest }
  end

  context "when no filter in params" do
    specify "#item_cards returns records from multiple years and companies" do
      expect(record_items)
        .to include("Death Star+1977", "Death Star+2000", "Monster Inc+2000")
    end

    specify "#count counts all" do
      expect(record.count).to eq(::Record.where(metric_id: metric.id).count)
    end
  end

  context "when year=latest is set in params" do
    # This is current behavior, but I'd prefer that params only affect queries in formats.
    specify "#item_cards returns only latest records" do
      with_latest_filter_params do
        expect(record_items).to eq(["Death Star+2001",
                                    "Monster Inc+2000",
                                    "Slate Rock and Gravel Company+2006",
                                    "SPECTRE+2000"])
      end
    end

    specify "#count counts only latest years" do
      with_latest_filter_params do
        expect(record.count)
          .to eq(::Record.where(metric_id: metric.id, latest: true).count)
      end
    end
  end

  describe ":table view" do
    def with_record_row
      with_tag :tr, with: { "data-details-mark": record_name } do
        with_tag :td, class: "header"
        with_tag :td, class: "data"
      end
    end

    describe ":filtered_content view" do
      subject do
        record.format.render_filtered_content
      end

      context "without filtered_body param" do
        it "has filter button, lists cards in bar view, and does not have chart " do
          is_expected.to have_tag ".filtered-results-header" do
            with_tag "._open-filters-button"
          end
          is_expected.to have_tag ".sorting-header"
          is_expected.to have_tag ".grouped-record-log-list"
          is_expected.not_to have_tag ".record-search-chart"
        end
      end

      context "without filtered_body params set to filtered_results_chart" do
        it "has filter button, has_chart, and does not list cards in bar view" do
          Card::Env.with_params filtered_body: "filtered_results_chart" do
            is_expected.to have_tag ".filtered-results-header"
            is_expected.to have_tag ".record-search-chart" do
              with_tag ".vis"
            end
            is_expected.not_to have_tag ".grouped-company-list"
          end
        end
      end
    end
  end
end
