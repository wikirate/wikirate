describe Card::Set::Right::Overview do
  describe "#handle_edit_article" do
    before do
      Card::Env.params[:edit_article] = true
      Card::Env.params[:citable] = sample_note
    end

    let(:citation) do
      "Death Star uses dark side of the Force "\
      "{{Death Star uses dark side of the Force|cite}}"
    end
    let(:company) { create "company1", type_id: Card::WikirateCompanyID }
    let(:topic) { create "topic1", type_id: Card::WikirateTopicID }
    let(:overview_name) { "#{company.name}+#{topic.name}+#{Card[:overview].name}" }
    context "missing view" do
      it "render editor with empty content with citation tips" do
        article = Card.new name: overview_name, type: "basic"
        html = article.format.render_missing
        id = "citable_note"
        expect(html).to have_tag("div", with: { class: "note-tip" }) do
          with_tag "textarea", with: { id: id }, text: /#{@citation}/
        end
        expect(html).to have_tag("div", with: { class: "prosemirror-editor" })
      end
    end

    context "core and titled_with_edits views" do
      it "renders editor with content with citation tips" do
        article = Card.create name: overview_name, type: "basic",
                              content: "hello world"
        html = article.format.render_core
        id = "citable_note"
        expect(html).to have_tag("div", with: { class: "note-tip" }) do
          with_tag "textarea", with: { id: id }, text: /#{@citation}/
        end
        prosemirror_tag = ["div", with: { class: "prosemirror-editor" }]
        expect(html).to have_tag(*prosemirror_tag) do
          with_tag "input", with: { name: "card[content]",
                                    value: "hello world" }
        end

        html = article.format.render_titled_with_edits
        expect(html).to have_tag("div", with: { class: "note-tip" }) do
          with_tag "textarea", with: { id: id }, text: /#{@citation}/
        end
        expect(html).to have_tag(*prosemirror_tag) do
          with_tag "input", with: { name: "card[content]",
                                    value: "hello world" }
        end
      end
    end
  end
end
