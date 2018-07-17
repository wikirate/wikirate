shared_examples "badge card" do |name, level, threshold|
  let(:card) { Card.fetch name }

  describe "#threshold" do
    subject { card.threshold }

    it { is_expected.to eq threshold }
  end

  describe "#badge_level" do
    subject { card.badge_level }

    it { is_expected.to eq level }
  end

  context "html format" do
    describe "view :level" do
      subject { render_view :level, name: name }

      it "has fontawesome" do
        is_expected.to have_tag "i.fa-certificate"
      end

      it "has correct level class" do
        is_expected.to have_tag "i.fa-certificate.#{level}"
      end
    end
  end
end
