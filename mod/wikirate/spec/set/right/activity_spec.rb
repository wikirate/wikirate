describe Card::Set::Right::Activity do
  before do
    login_as "joe_user" 
    @source_page = create_page "http://wagn.org"
    # the below "create" will make a acts without card_id due to the abort :success
    create_page_with_sourcebox "http://wagn.org"
  end
  describe "core view" do
    it "renders view" do
      activity_card = Card.fetch "joe_user+activity"
      html = activity_card.format.render_core
      expect(html).to have_tag("div",:with=>{:class=>"activity"}) do
        with_tag "span",:with=>{:class=>"time"},:text=>"less than a minute ago"
        with_tag "div",:text=>/created a new source/ do
          with_tag "a",:with=>{:href=>"/#{@source_page.cardname.url_key}"},:text=>@source_page.name
        end
      end 
    end
  end
end