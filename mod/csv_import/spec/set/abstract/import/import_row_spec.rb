RSpec.describe Card::Set::Abstract::Import::ImportRow do
  context "exact match" do
    let(:row) do
      row =
        Card::Set::Abstract::Import::ImportRow.new(
          { file_company: "Google" }, ["Google"], 1, Card["A"].format(:html)
        )
      row.render
    end
    it "has class 'table-success'" do
      expect(row[:class]).to eq "table-success"
    end

    it "has csv row index as data attribute" do
      expect(row[:data][:csv_row_index]).to eq 1
    end

    specify "content" do
      expect(row[:content]).to have_tag :input, with: { type: "checkbox" }
    end
  end
end
