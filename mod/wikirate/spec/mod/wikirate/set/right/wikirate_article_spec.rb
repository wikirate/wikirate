describe Card::Set::Right::WikirateArticle do
  describe "views" do
    it "return edit view when rendering content view if params[:edit_article] is true" do 
      Card::Env.params[:edit_article] = true
      company = Card.create :name=>"company1",:type=>"company"
      topic = Card.create :name=>"topic1",:type=>"topic"
      article = Card.create :name=>"company1+topic1+article",:type=>"basic",:content=>"hello world"
      html = article.format.render_content.gsub(/company1\+topic1\+article[\-\d]+/,"company1+topic1+article")
      expect(html).to eq(article.format.render_edit.gsub(/company1\+topic1\+article[\-\d]+/,"company1+topic1+article"))
    end
    it "renders content view if params[:edit_article] is false/nil" do 

    end
    it "return edit view when rendering missing view if params[:edit_article] is true" do 
      Card::Env.params[:edit_article] = true
      company = Card.create :name=>"company1",:type=>"company"
      topic = Card.create :name=>"topic1",:type=>"topic"
      article = Card.create :name=>"company1+topic1+article",:type=>"basic",:content=>"hello world"
      

      #<textarea class="tinymce-textarea card-content" cols="40" id="company1+topic1+article-1416413328-1" name="card[content]" rows="3">
      #<textarea class="tinymce-textarea card-content" cols="40" id="company1+topic1+article-1416413328-2" name="card[content]" rows="3">
      #these 2 lines explain everything
      html = article.format.render_missing.gsub(/company1\+topic1\+article[\-\d]+/,"company1+topic1+article")
      _html = article.format.render_edit.gsub(/company1\+topic1\+article[\-\d]+/,"company1+topic1+article")
      expect(html).to eq(_html)
    end
    it "renders missing view if params[:edit_article] is false/nil" do 

    end
    it "renders editor view if citable" do 

    end
    it "renders editor view normal" do 

    end
  end
end
