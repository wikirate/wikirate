describe Card::Set::Type::Source::Creation do
  def card_subject
    Card.new type_id: Card::SourceID
  end

  context "when adding while researching an answer (sourcebox)" do
    before do
      Card::Env.params[:answer] = "Jedi+deadliness+Death_Star+1977"
    end

    describe "#new" do
      # FIXME:
      # Shouldn't re-render every time. But compound expectations (".and")
      # weren't working...
      it "prepopulates company from answer" do
        expect_view(:new).to have_field_with_value("Company", "Death_Star")
      end

      it "prepopulates title from search term" do
        Card::Env.params[:source_search_term] = "https://xkcd.com/4/"
        expect_view(:new).to have_field_with_value("Title", "xkcd: Landscape (sketch)")
      end

      it "has special hidden success tag" do
        expect_view(:new)
          .to have_tag "input", with: { type: "hidden",
                                        name: "success[view]",
                                        value: "source_selector" }
      end

      it "has special cancel button" do
        expect_view(:new)
          .to have_tag "a.btn.cancel-button",
                       with: { "data-slot-selector": ".sourcebox-view" }
      end
    end

    def have_field_with_value field, value
      have_tag "input", with: { name: "card[subcards][+#{field}][content]", value: value }
    end
  end

  context "when adding directly (no sourcebox)" do
    describe "#new" do
      it "has no special success tag" do
        expect_view(:new).not_to have_tag("input", with: { name: "success[view]"})
      end
    end
  end
end
