describe Card::Set::Right::WikirateArticle do
  describe "#handle_edit_article" do
    before do
      Card::Env.params[:edit_article] = true
      @company = Card.create :name=>"company1",:type=>"company"
      @topic = Card.create :name=>"topic1",:type=>"topic"
      @claim = get_a_sample_claim
      Card::Env.params[:citable]=@claim.name
      @citation = "Death Star uses dark side of the Force {{Death Star uses dark side of the Force|cite}}"
    end
    context "missing view" do
      it "render editor with empty content with citation tips" do
        article = Card.new :name=>"#{@company.name}+#{@topic.name}+article",:type=>"basic"
        html = article.format.render_missing
        
        expect(html).to have_tag("div",:with=>{:class=>"claim-tip"}) do
          with_tag "textarea",:with=>{:id=>"citable_claim"},:text=>/#{@citation}/
        end
        expect(html).to have_tag("textarea",:with=>{:class=>"tinymce-textarea",:name=>"card[content]"})

      end
    end
    context "content and titled_with_edits views" do
      it "render editor with content with citation tips" do
        article = Card.create :name=>"#{@company.name}+#{@topic.name}+article",:type=>"basic",:content=>"hello world"
        html = article.format.render_content
        expect(html).to have_tag("div",:with=>{:class=>"claim-tip"}) do
          with_tag "textarea",:with=>{:id=>"citable_claim"},:text=>/#{@citation}/
        end
        expect(html).to have_tag("textarea",:with=>{:class=>"tinymce-textarea",:name=>"card[content]"},:text=>/hello world/)

        html = article.format.render_titled_with_edits
        expect(html).to have_tag("div",:with=>{:class=>"claim-tip"}) do
          with_tag "textarea",:with=>{:id=>"citable_claim"},:text=>/#{@citation}/
        end
        expect(html).to have_tag("textarea",:with=>{:class=>"tinymce-textarea",:name=>"card[content]"},:text=>/hello world/)

      end
    end
  end
end
