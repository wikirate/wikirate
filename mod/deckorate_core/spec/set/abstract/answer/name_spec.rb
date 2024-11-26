RSpec.describe Card::Set::Abstract::Answer::Name do
  def answer year
    "Jedi+disturbances in the Force+Death Star+#{year}".card
  end

  describe ":validate_year_change" do
    def update_year_to year
      answer(1977).update! subcards: { "+Year" => { "content" => year.to_s } }
    end

    it "handles new year passed as subcard" do
      update_year_to 2016
      answer = answer 2016
      expect(answer).to be_real
      expect(answer.fetch(:year)).to be_nil
    end
  end
end
