require_relative "../../support/shared_csv_import"

describe Card::Set::Type::SourceImportFile do
  def url name
    "http://www.wikiwand.com/en/#{name.tr(" ","_")}"
  end

  include_context "csv import" do
    let(:csv_row_class) { CSVRow::Structure::SourceCSV }
    let(:import_card) { Card["source import test"] }
    let(:data) do
      {
        exact_match:         ["Death Star", "2014", "Force Report",
                              url("Death Star"), "aaaaaah"],
        duplicate_in_file:   ["Monter Inc", "2017", "Monster Report",
                              "http://www.wikiwand.com/en/Death_Star", "know me?"],
        alias_match:         ["Google", "2014", "Monster Report",
                              url("Google"), "aaaaaah"],
        partial_match:       ["Monster", "2014", "Monster Report",
                              url("Monster"), "aaaaaah"],
        existing_url:        ["Monster Inc", "2014", "Monster Report",
                              url("Star_Wars"), "aaaaaah"],
        existing_without_title: ["Monster Inc", "2014", "Monster Report",
                                 url("Darth_Vader"), "ch ch"],
        missing_url:         ["Monster Inc", "2014", "Monster Report",
                              "", "aaaaaah"],
        missing_company:     ["", "2014", "Monster Report",
                              url("Monsters,_Inc."), "aaaaaah"],
        missing_report_type: ["Monter Inc", "2014",
                              url("Monsters,_Inc."), "aaaaaah"],
        missing_year:        ["Monter Inc", "", "Monster Report",
                              url("Monsters,_Inc."), "aaaaaah"],
      }
    end
  end

  before do
    login_as "joe_admin"
  end

  let(:csv_path) { File.expand_path "../source_import_test.csv", __FILE__ }

  # TODO: do it without controller
  describe "import action", type: :controller do
    routes { Decko::Engine.routes }
    before { @controller = CardController.new }


    example "source with exact match" do
      source_file = trigger_import_request exact_match: { match_type: :exact }

      source_card = Card.search(type: "source",
                                right_plus: [{ codename: "wikirate_link" },
                                             { content: "http://placehold.it/100x100" }]).first
      #source_card = source_file.subcards[source_file.subcards.to_a[0]]
      expect(source_card)
        .to be_a(Card)
        .and have_a_field(:wikirate_title).with_content(source_title)
        .and have_a_field(:report_type).pointing_to("Conflict Minerals Report")
        .and have_a_field(:wikirate_company).pointing_to("Apple Inc")
        .and have_a_field(:year).pointing_to "2014"
    end

    context "existing sources" do
      context "with fields" do
        before do
          trigger_import_request existing_url: {
            match_type: :exact,
            corrections: { title: "Obi Wan" }
          }
        end

        let(:source_card) do
          sample_source("Death_Star")
        end

        it "won't update existing source title" do
          expect(source_card).to have_a_field(:wikirate_title).with_content "Star Wars"
        end

        it "updates exisitng source" do
          expect(source_card)
            .to have_a_field(:report_type).pointing_to("Monster Report")
            .and have_a_field(:wikirate_company).pointing_to("Monster Inc")
            .and have_a_field(:year).pointing_to "2013"
        end
      end

      context "without title" do
        let(:source_card) { sample_source "Darth_Vader" }

        before do
          trigger_import_request existing_without_title: { match_type: :exact,
                                                           corrections: { title: "Anakin" } }
        end

        it "updates existing source" do
          expect(source_card).to have_a_field(:wikirate_title).with_content "Anakin"

          feedback = @source_import_file.success[:updated_sources]
          expect(feedback).to include(["1", @source_card.name])
        end

        it "renders correct feedback html" do
          Card::Env[:params] = @source_import_file.success.raw_params
          expect(@source_import_file.format.render_core).to(
            have_tag(:div, with: { class: "alert alert-warning" }) do
              with_tag :h4, text: "Existing sources updated"
              with_tag :ul do
                with_tag :li, text: "Row 1: #{@source_card.name}"
              end
            end
          )
        end
      end
    end

    context "duplicated sources in file" do
      it "only adds the first source" do
        trigger_import exact_match: { corrections: { title: "A" } },
                       duplicate_in_file: { correctinos: { title: "B" } }

        expect(sample_source("Death_Star"))
          .to be_a(Card)
          .and have_a_field(:wikirate_title).with_content("A")
          .and have_a_field(:report_type).pointing_to("Force Report")
          .and have_a_field(:wikirate_company).pointing_to("Death Star")
          .and have_a_field(:year).pointing_to "2014"

        expect(status[:reports][:duplicates_in_file]).to contain_exactly
        "#2: http://www.wikiwand.com/en/Death_Star"
      end

      it "reports duplicates" do
        Card::Env[:params] = @source_file.success.raw_params
        html = @source_file.format.render_core
        css_class = "alert alert-warning"
        expect(html).to have_tag(:div, with: { class: css_class }) do
          with_tag :h4, text: "Duplicated sources in import file."\
                              " Only the first one is used."
          with_tag :ul do
            with_tag :li, text: "Row 2: http://example.com/12333214"
          end
        end
      end
    end

    context "missing fields" do
      let(:errors) do
        Card["source import test", :import_status].status[:errors].values.flatten
      end

      it "misses source field", as_bot: true do
        trigger_import(:missing_url)
        expect(errors).to contain_exactly "value for source missing"
      end
      it "misses company field" do
        trigger_import(:missing_company)
        expect(errors).to contain_exactly "value for company missing"
      end
      it "misses report type field" do
        trigger_import(:missing_report_type)
        expect(errors).to contain_exactly "value for company missing"
      end
      it "misses year field" do
        trigger_import_request(:missing_year)
        expect(errors).to contain_exactly "value for year missing"
      end
    end
  end

  describe "view :import_table" do
    include_context "table row matcher"

    example "shows correctly import table" do
      table = import_card_with_rows(:exact_match, :partial_match, :alias_match)
                .format._render_import_table
      expect(table).to have_tag("table", with: { class: "import_table" }) do
        with_row index: 0,
                 context: :success,
                 checked: true,
                 match: :exact,
                 suggestion: "Death Star",
                 fields: ["Death Star", "2014", "Force Report", url("Death_Star")]

        with_row index: 1,
                 context: :info,
                 checked: true,
                 match: :partial,
                 suggestion: "Monster Inc",
                 fields: ["Monster Inc", "Monster", "2014", "Monster Report", url("Monster")]

        with_row index: 2,
                 context: :success,
                 checked: true,
                 match: :alias,
                 suggestion: "Google Inc.",
                 fields: ["Google Inc.", "Google", "2014", "Monster Report", url("Google")]
      end
    end
  end
end
