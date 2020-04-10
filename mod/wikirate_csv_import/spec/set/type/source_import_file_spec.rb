require_relative "../../support/shared_csv_import"

RSpec.describe Card::Set::Type::SourceImportFile do
  # require_relative "../../support/shared_csv_import"
#
  # def url name
  #   "https://www.wikiwand.com/en/#{name.tr(' ', '_')}"
  # end
#
  # def source_card key
  #   m = data[key][3].match(%r{en/(.+)$})
  #   source_card_for m[1]
  # end
#
  # def source_card_for sourcename=nil
  #   Card.search(
  #     type_id: Card::SourceID,
  #     right_plus: [:wikirate_link.cardname, { content: url(sourcename) }],
  #     limit: 1
  #   ).first
  # end
#
  # before do
  #   login_as "joe_admin"
  # end
#
  # let(:csv_path) { File.expand_path "../source_import_test.csv", __FILE__ }
#
#
  # context "existing sources" do
  #   context "with fields" do
  #     before do
  #       Card::Env.params[:conflict_strategy] = :override
  #       trigger_import existing_url: {
  #         match_type: :exact,
  #         corrections: { title: "Obi Wan" }
  #       }
  #       Card::Env.params[:conflict_strategy] = nil
  #     end
#
  #     subject { source_card(:existing_url) }
#
  #     it "won't update existing source title" do
  #       is_expected.to have_a_field(:wikirate_title).with_content "Star Wars"
  #     end
#
  #     it "updates existing source attributes" do
  #       is_expected
  #         .to have_a_field(:report_type).pointing_to("Monster Report")
  #         .and have_a_field(:wikirate_company).pointing_to("Monster_Inc")
  #         .and have_a_field(:year).pointing_to "2014"
  #     end
  #   end
#
  #   context "without title" do
  #     before do
  #       source_card_for("Darth Vader").wikirate_title_card.delete!
  #     end
  #     it "updates title" do
  #       Card::Env.params[:conflict_strategy] = :override
  #       trigger_import existing_without_title: { company_match_type: :exact,
  #                                                corrections: { title: "Anakin" } }
  #       Card::Env.params[:conflict_strategy] = nil
  #       expect(source_card(:existing_without_title))
  #         .to have_a_field(:wikirate_title).with_content "Anakin"
  #     end
  #   end
  # end
#
  # context "duplicated source in file" do
  #   it "only adds the first source" do
  #     trigger_import exact_match: { corrections: { title: "A" } },
  #                    duplicate_in_file: { corrections: { title: "B" } }
#
  #     expect(source_card(:exact_match))
  #       .to be_a(Card)
  #       .and have_a_field(:wikirate_title).with_content("A")
  #       .and have_a_field(:report_type).pointing_to("Force Report")
  #       .and have_a_field(:wikirate_company).pointing_to("Death Star")
  #       .and have_a_field(:year).pointing_to "2014"
  #     expect(status[:reports][1])
  #       .to contain_exactly "https://www.wikiwand.com/en/Death_Star duplicate in this file"
  #     expect(status[:counts][:skipped]).to eq 1
  #   end
  # end
end
