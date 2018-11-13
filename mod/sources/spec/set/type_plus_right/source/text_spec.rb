describe Card::Set::TypePlusRight::Source::Text do
  describe "while editing a file source" do
    before do
      login_as "joe_user"
      text = "There are 2 hard problems in computer science: cache "\
             "invalidation, naming things, and off-by-1 errors."
      @text_source = create_source text
      @another_user = Card.create! name: "joe_user_again", type_id: Card::UserID
    end
    context "users is not the author" do
      it "shows non-editing message " do
        login_as @another_user.name
        source_text_card = @text_source.fetch trait: :text
        html = source_text_card.format.render_edit
        expect(html).to include(%{Only <a class="known-card" href="/Joe_User">Joe User</a>(author) can edit this text source.})
      end
      it "blocks updating content" do
        login_as @another_user.name
        source_text_card = @text_source.fetch trait: :text
        source_text_card.content = "There are two ways of constructing a software design. One way is to make it so simple that there are obviously no deficiencies. And the other way is to make it so complicated that there are no obvious deficiencies."
        source_text_card.save
        expect(source_text_card).not_to be_valid
        expect(source_text_card.errors).to have_key :text
        expect(source_text_card.errors[:text]).to include(" can only be edited by author")
      end
    end
  end
end
