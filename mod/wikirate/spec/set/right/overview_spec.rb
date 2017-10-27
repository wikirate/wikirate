describe Card::Set::Right::Overview do
  before do
    Card::Env.params[:edit_article] = true
    Card::Env.params[:citable] = sample_note.name
  end

  let(:article) { Card["Death Star", "Force", :overview] }
  let(:content) { "I am your father! {{Death Star uses dark side of the Force|cite}}" }
  let(:citation) do
    "Death Star uses dark side of the Force "\
    "{{Death Star uses dark side of the Force|cite}}"
  end

  def have_citation_tips
    have_tag("div.note-tip") do
      with_tag "textarea#citable_note", text: /#{citation}/
    end
  end

  describe "missing view" do
    subject { article.format.render! :missing }

    it "renders editor with empty content and citation tips" do
      is_expected.to have_citation_tips
      is_expected.to have_tag "div.prosemirror-editor"
    end
  end

  describe "core view" do
    subject { article.format.render! :core }

    it "renders editor with content and citation tips" do
      is_expected.to have_citation_tips
      is_expected.to have_tag("div.prosemirror-editor") do
        with_tag "input", with: { name: "card[content]", value: content }
      end
    end
  end

  describe "titled_with_edits view" do
    subject { article.format.render! :titled_with_edits }

    it "renders editor with content and citation tips" do
      is_expected.to have_citation_tips
      is_expected.to have_tag("div.prosemirror-editor") do
        with_tag "input", with: { name: "card[content]", value: content }
      end
    end
  end
end
