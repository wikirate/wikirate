require_relative "../../support/shared_csv_data"
require_relative "../../support/shared_csv_import"


describe Card::Set::Type::AnswerImportFile, type: :controller do
  routes { Decko::Engine.routes }
  before { @controller = CardController.new }

  describe "import table" do
    include_context "csv import" do
      let(:csv_row_class) { AnswerCSVRow }
      let(:import_card) { Card["answer import test"] }
      let(:data) do
        {
          exact_match: ["Jedi+disturbances in the Force", "Death Star", "2017", "yes", "http://google.com", ""],
          alias_match: ["Jedi+disturbances in the Force", "Google", "2017", "yes", "http://google.com", ""],
          partial_match: ["Jedi+disturbances in the Force", "Sony", "2017", "yes", "http://google.com", ""],
          no_match: ["Jedi+disturbances in the Force", "New Company", "2017", "yes", "http://google.com", ""],
          not_a_metric: ["Not a metric", "Monster Inc", "2017", "yes", "http://google.com", ""]
        }
      end
    end

    let(:format) { import_card_with_data.format(:html) }

    it "sorts by match type" do
      #allow(card).to receive(:file).and_return true
      #allow(card).to receive(:csv_file).and_return csv_file
      expect(format.render_import_table).to have_tag :table do
        with_tag :tbody do
          with_text /Not a metric.+New Company.+Sony.+Google.+Death Star/m
        end
      end
    end
  end

  describe "import csv file" do
    include_context "csv import" do
      let(:csv_row_class) { AnswerCSVRow }
      let(:import_card) { Card["answer import test"] }
      let(:data) do
        {
          exact_match: ["Jedi+disturbances in the Force", "Death Star", "2017", "yes", "http://google.com", ""],
          alias_match: ["Jedi+disturbances in the Force", "Google", "2017", "yes", "http://google.com", ""],
          partial_match: ["Jedi+disturbances in the Force", "Sony", "2017", "yes", "http://google.com", ""],
          no_match: ["Jedi+disturbances in the Force", "New Company", "2017", "yes", "http://google.com", ""],
          not_a_metric: ["Not a metric", "Monster Inc", "2017", "yes", "http://google.com", ""],
          not_a_company: ["Jedi+disturbances in the Force", "A", "2017", "yes", "http://google.com/4", ""],
          company_missing: ["Jedi+disturbances in the Force", "", "2017", "yes", "http://google.com/5", ""],
          missing_and_invalid: ["Not a metric", "", "2017", "yes", "http://google.com/6", ""],
          conflict_same_value_same_source: ["Jedi+disturbances in the Force", "Death Star", "2000", "yes", "http://www.wikiwand.com/en/Opera", ""],
          conflict_same_value_different_source: ["Jedi+disturbances in the Force", "Death Star", "2000", "yes", "http://google.com/9", ""],
          conflict_different_value: ["Jedi+disturbances in the Force", "Death Star", "2000", "no", "http://google.com/10", ""],
          invalid_value: ["Jedi+disturbances in the Force", "Death Star", "2017", "100", "http://google.com/11", ""]
        }
      end
    end

    before do
      login_as "joe_admin"
    end

    example "create new import card and import", as_bot: true do
      real_csv_file = File.open File.expand_path("../../../support/test.csv", __FILE__)
      import_card = create "test import",
                           type_id: Card::AnswerImportFileID,
                           answer_import_file: real_csv_file
      expect_card("test import").to exist.and have_file.of_size(be > 400)
      expect_card("Jedi+disturbances in the Force+Death Star+2017+value").not_to exist
      params = import_params exact_match: { extra_data: { match_type: :exact } }
      post :update, xhr: true, params: { id: "~#{import_card.id}", import_data: params }
      expect_card("Jedi+disturbances in the Force+Death Star+2017+value").to exist
    end

    it "imports others if one fails" do
      trigger_import_request :exact_match, :invalid_value
      expect_card("Jedi+disturbances in the Force+Death Star+2017+value")
        .to exist.and have_db_content("yes")
    end

    describe "duplicates" do

    end
  end
  example "empty import" do

  end

end
