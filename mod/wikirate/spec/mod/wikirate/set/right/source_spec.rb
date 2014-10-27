
describe Card::Set::Right::Source do
  describe "editor view when in plus right" do 
    it "shows the editor view even in inclustion with its own structure rule" do 
      claim = create_claim "testclaimforever"
      plus_source_card = Card[claim.name+"+source"]
      expect(plus_source_card.format.render_editor).not_to eq(plus_source_card.format.render_blank) 
    end
  end
end