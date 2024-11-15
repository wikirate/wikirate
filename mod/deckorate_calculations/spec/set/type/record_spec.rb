RSpec.describe Card::Set::Type::Record do
  context "with Rating" do
    let(:record) { Card.fetch "Jedi+darkness_rating+Death_Star+1977" }

    example "#direct_dependee_records" do
      expect(record.direct_dependee_records.count).to eq(2)
    end

    example "#dependee_records" do
      expect(record.dependee_records.count).to eq(4)
    end

    example "#calculated_verification" do
      expect(record.calculated_verification).to eq(1)
    end
  end
end
