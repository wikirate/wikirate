RSpec.describe Card::Set::Abstract::Record::Name do
  def record year
    "Jedi+disturbances in the Force+Death Star+#{year}".card
  end

  describe ":validate_year_change" do
    def update_year_to year
      record(1977).update! subcards: { "+Year" => { "content" => year.to_s } }
    end

    it "handles new year passed as subcard" do
      update_year_to 2016
      record = record 2016
      expect(record).to be_real
      expect(record.fetch(:year)).to be_nil
    end
  end
end
