describe Card::Set::Right::Overview do
  describe '#handle_edit_article' do
    before do
      Card::Env.params[:edit_article] = true
      @company = Card.create name: "company1", type_id: Card::WikirateCompanyID
      @topic = Card.create name: "topic1", type_id: Card::WikirateTopicID
      @claim = get_a_sample_note
      Card::Env.params[:citable] = @claim.name
      @citation = "Death Star uses dark side of the Force "\
                  "{{Death Star uses dark side of the Force|cite}}"
    end

    context "missing view" do
      it "render editor with empty content with citation tips" do
        name = "#{@company.name}+#{@topic.name}+#{Card[:overview].name}"
        article = Card.new name: name, type: "basic"
        html = article.format.render_missing
        id = "citable_note"
        expect(html).to have_tag("div", with: { class: "note-tip" }) do
          with_tag "textarea", with: { id: id }, text: /#{@citation}/
        end
        expect(html).to have_tag("div", with: { class: "prosemirror-editor" })
      end
    end

    context "core and titled_with_edits views" do
      it "render editor with content with citation tips" do
        overview_name = "#{@company.name}+#{@topic.name}+"\
                        "#{Card[:overview].name}"
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
