require_relative "../../../support/shared_answer_csv_row"

RSpec.describe Card::Set::Abstract::Import::ExecuteImport do
  let(:card) { Card["A"].with_set(described_class) }
  describe "#data_import?" do
    subject { card.data_import? }

    example "no data given" do
      is_expected.to be_falsey
    end

    example "an empty hash given" do
      Card::Env.params[:import_rows] = {}
      is_expected.to be_falsey
    end

    example "an import value" do
      Card::Env.params[:import_rows] = { 1 => true }
      is_expected.to be_truthy
    end
  end
end
