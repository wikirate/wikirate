RSpec.describe Card::Set::TypePlusRight::Metric::License do
  let(:researched) { "Jedi+deadliness".card }
  let(:other_researched) { "Jedi+disturbances in the force".card }
  let(:score) { researched.fetch "Joe User" }
  # this rating depends on all the above metrics
  let(:rating) { "Jedi+darkness rating".card }
  let(:dataset) { "Evil Dataset".card }

  let(:nc_license) { "CC BY-NC 4.0" }
  let(:sa_license) { "CC BY-SA 4.0" }
  let(:nc_sa_license) { "CC BY-NC-SA 4.0" }

  describe "event: cascade_license" do
    it "changes license of direct and indirect dependers" do
      researched.license_card.update! content: nc_license
      expect(score.license).to eq nc_license
      expect(rating.license).to eq nc_license
    end

    it "determines compatible licenses" do
      researched.license_card.update! content: nc_license
      other_researched.license_card.update! content: sa_license

      expect(rating.license).to eq nc_sa_license
    end

    it "updates dataset licesnse" do
      other_researched.license_card.update! content: sa_license
      expect(dataset.license).to eq sa_license
    end
  end
end
