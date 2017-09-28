require_relative "../../support/shared_csv_data"

module CSVData
  DATA = [
    ["Jedi+disturbances in the Force", "Death Star", "2017", "yes", "http://google.com", ""],
    ["Jedi+disturbances in the Force", "Google", "2017", "yes", "http://google.com", ""],
    ["Jedi+disturbances in the Force", "Sony", "2017", "yes", "http://google.com", ""],
    ["Jedi+disturbances in the Force", "New Company", "2017", "yes", "http://google.com", ""],
    ["Not a metric", "Monster Inc", "2017", "yes", "http://google.com", ""]
  ]

  def csv_io
    StringIO.new DATA.map { |rows| rows.join "," }.join "\n"
  end

  def real_csv_file
    File.open File.expand_path("../../../support/test.csv", __FILE__)
  end

  def csv_file
    CSVFile.new csv_io, AnswerCSVRow
  end
end


describe Card::Set::Type::AnswerImportFile, type: :controller do
  routes { Decko::Engine.routes }
  include CSVData
  before do
    @controller = CardController.new
  end


  def card_route_to opts = {}
    route_to opts.merge(controller: "card")
  end

  include_context "csv data"
  let(:card) { Card["A"].with_set(described_class) }
  let(:format) { card.format_with_set(described_class, :html) }
  specify do
    allow(card).to receive(:file).and_return true
    allow(card).to receive(:csv_file).and_return answer_csv_file
    expect(format.render_import_table).to have_tag "table"
  end

  describe "import table" do
    it "sorts by match type" do
      allow(card).to receive(:file).and_return true
      allow(card).to receive(:csv_file).and_return csv_file
      expect(format.render_import_table).to have_tag :table do
        with_tag :tbody do
          with_text /Not a metric.+New Company.+Sony.+Google.+Death Star/m
        end
      end
    end
  end

  describe "import csv file" do
    IMPORT_DATA =
      (%i[exact_match alias_match partial_match no_match] + # valid data
       %i[not_a_metric not_a_company company_missing missing_and_invalid ] + # invalid data
       %i[conflict_same_value_same_source conflict_same_value_different_source] + # conflicts with existing data
       %i[conflict_different_value duplicate_with_exact_match] +
       %i[invalid_value]).freeze # failures

    LINE = IMPORT_DATA.zip(0..IMPORT_DATA.size).to_h.freeze

    def import_params *args
      if args.size == 1 && args.first.is_a?(Hash)
        args = args.first
      end

      case args
      when Array
        args.each_with_object({}) do |n, h|
          h[LINE[n]] = { import: true }
        end
      when Hash
        args.each_with_object({}) do |(k, v), h|
          h[LINE[k]] = { import: true }.merge v
        end
      end
    end

    before do
      login_as "joe_admin"
    end

    let(:import_card) do
      create "test import",
             type_id: Card::AnswerImportFileID,
             answer_import_file: real_csv_file
    end

    # TODO: add import file card to seed data
    specify "test setup works" do
      import_card
      expect_card("test import").to exist.and have_file.of_size(be > 400)
    end

    example "import exact match", as_bot: true do
      expect_card("Jedi+disturbances in the Force+Death Star+2017+value").not_to exist
      post_import exact_match: { extra_data: { match_type: :exact } }
      expect_card("Jedi+disturbances in the Force+Death Star+2017+value").to exist
                                                                               .and have_db_content("yes")
    end

    it "imports others if one fails" do
      post_import :exact_match, :invalid_value
      expect_card("Jedi+disturbances in the Force+Death Star+2017+value").to exist
        .and have_db_content("yes")
    end

    describe "duplicates" do

    end


    def post_import *data
      post :update, xhr: true, params: { id: "~#{import_card.id}",
                                         import_data: import_params(*data) }
    end

  end
  example "empty import" do

  end

end
