describe Card::Set::Right::Overview do
  describe "#handle_edit_article" do
    before do
      Card::Env.params[:edit_general_overview] = true
    end

    context "left part does not exist" do
      it "shows the new editor view" do
        new_card = Card.new name: "Shamesung+overview"
        html = new_card.format.render_new
        expect(html).to have_tag("div", with: { id: "Shamesung+overview",
                                                class: "new-view" })
      end
    end
  end
end
