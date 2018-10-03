require_relative "../../support/shared_csv_import"

RSpec.describe Card::Set::Type::SourceImportFile do
  def url name
    "http://www.wikiwand.com/en/#{name.tr(' ', '_')}"
  end

  include_context "csv import" do
    let(:csv_row_class) { CSVRow::Structure::SourceCSV }
    let(:import_card) { Card["source import test"] }
    let(:data) do
      {
        exact_match: ["Death Star", "2014", "Force Report",
                      url("Death Star"), "a title"],
        duplicate_in_file: ["Monter Inc", "2017", "Monster Report",
                            "http://www.wikiwand.com/en/Death_Star", "know me?"],
        alias_match: ["Google", "2014", "Monster Report",
                      url("Google"), "aaaaaah"],
        partial_match: ["Monster", "2014", "Monster Report",
                        url("Monster"), "aaaaaah"],
        existing_url: ["Monster Inc", "2014", "Monster Report",
                       url("Star_Wars"), "aaaaaah"],
        existing_without_title: ["Monster Inc", "2014", "Monster Report",
                                 url("Darth_Vader"), "ch ch"],
        missing_url: ["Monster Inc", "2014", "Monster Report",
                      "", "aaaaaah"],
        missing_company: ["", "2014", "Monster Report",
                          url("Monsters,_Inc."), "aaaaaah"],
        missing_report_type: ["Monter Inc", "2014", "",
                              url("Monsters,_Inc."), "aaaaaah"],
        missing_year: ["Monter Inc", "", "Monster Report",
                       url("Monsters,_Inc."), "aaaaaah"]
      }
    end
  end

  def source_card key
    m = data[key][3].match(%r{en/(.+)$})
    sample_source m[1]
  end

  before do
    login_as "joe_admin"
  end

  let(:csv_path) { File.expand_path "../source_import_test.csv", __FILE__ }

  # TODO: do it without controller
  describe "import action" do # , type: :controller do
    # routes { Decko::Engine.routes }
    # before { @controller = CardController.new }

    example "source with exact match" do
      trigger_import exact_match: { match_type: :exact }

      expect(source_card(:exact_match))
        .to be_a(Card)
        .and have_a_field(:wikirate_title).with_content("a title")
        .and have_a_field(:report_type).pointing_to("Force Report")
        .and have_a_field(:wikirate_company).pointing_to("Death Star")
        .and have_a_field(:year).pointing_to "2014"
    end

    context "existing sources" do
      context "with fields" do
        before do
          Card::Env.params[:conflict_strategy] = :override
          trigger_import existing_url: {
            match_type: :exact,
            corrections: { title: "Obi Wan" }
          }
          Card::Env.params[:conflict_strategy] = nil
        end

        subject { source_card(:existing_url) }

        it "won't update existing source title" do
          is_expected.to have_a_field(:wikirate_title).with_content "Star Wars"
        end

        it "updates existing source attributes" do
          is_expected
            .to have_a_field(:report_type).pointing_to("Monster Report")
            .and have_a_field(:wikirate_company).pointing_to("Monster Inc")
            .and have_a_field(:year).pointing_to "2014"
        end
      end

      context "without title" do
        it "updates title" do
          Card::Env.params[:conflict_strategy] = :override
          trigger_import existing_without_title: { company_match_type: :exact,
                                                   corrections: { title: "Anakin" } }
          Card::Env.params[:conflict_strategy] = nil
          expect(source_card(:existing_without_title))
            .to have_a_field(:wikirate_title).with_content "Anakin"
        end
      end
    end

    context "duplicated source in file" do
      it "only adds the first source" do
        trigger_import exact_match: { corrections: { title: "A" } },
                       duplicate_in_file: { corrections: { title: "B" } }

        expect(source_card(:exact_match))
          .to be_a(Card)
          .and have_a_field(:wikirate_title).with_content("A")
          .and have_a_field(:report_type).pointing_to("Force Report")
          .and have_a_field(:wikirate_company).pointing_to("Death Star")
          .and have_a_field(:year).pointing_to "2014"
        expect(status[:reports][1])
          .to contain_exactly "http://www.wikiwand.com/en/Death_Star duplicate in this file"
        expect(status[:counts][:skipped]).to eq 1
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
        expect(errors).to contain_exactly "value for report_type missing"
      end
      it "misses year field" do
        trigger_import(:missing_year)
        expect(errors).to contain_exactly "value for year missing"
      end
    end
  end

  describe "view :import_table" do
    include_context "table row matcher"

    example "shows correctly import table" do
      table = import_card_with_rows(:exact_match, :partial_match, :alias_match)
              .format._render_import_table
      expect(table).to have_tag("table", with: { class: "_import-table" }) do
        with_row index: 0,
                 context: :success,
                 checked: true,
                 match: :exact,
                 suggestion: "Death Star",
                 fields: ["Death Star", "2014", "Force Report",
                          url("Death_Star")]

        with_row index: 1,
                 context: :info,
                 checked: true,
                 match: :partial,
                 suggestion: "Monster Inc",
                 fields: ["Monster Inc", "Monster", "2014", "Monster Report",
                          url("Monster")]

        with_row index: 2,
                 context: :success,
                 checked: true,
                 match: :alias,
                 suggestion: "Google LLC",
                 fields: ["Google LLC", "Google", "2014", "Monster Report",
                          url("Google")]
      end
    end
  end
end
