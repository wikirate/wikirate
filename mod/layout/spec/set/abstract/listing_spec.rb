describe Card::Set::Abstract::Listing do
  describe "#listing" do
    let(:research_group_listing) do
      Card["Jedi"].format(:html).render_listing
    end

    it "includes left middle and right" do
      expect(research_group_listing)
          .to have_tag :div, with: { class: "listing" } do
        with_tag "div.listing-left"
        with_tag "div.listing-middle"
        with_tag "div.listing-right"
      end
    end
  end
end
