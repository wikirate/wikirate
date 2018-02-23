describe Card::Set::Abstract::BsBadge do
  describe "#labeled_badge" do
    subject do
      # research group includes Abstract::BsBadge
      Card["Jedi"].format(:html).labeled_badge 5, "Cats"
    end

    it "includes badge and label" do
      is_expected.to have_tag "span.labeled-badge" do
        with_tag("span.badge") { "5" }
        with_tag("label.mr-2") { "Cats" }
      end
    end
  end
end
