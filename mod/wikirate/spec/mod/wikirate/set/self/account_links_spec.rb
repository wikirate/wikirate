# -*- encoding : utf-8 -*-

describe Card::Set::Self::AccountLinks do
  before do
    
    @account_link = Card[:account_links]
  end
  describe "raw view" do
    context "when the user signed in" do
      it do
        login_as 'Anonymous'
        rendered_html = @account_link.format(:format=>:html).render_raw 

        expect(rendered_html).to have_tag("span", :with=>{:id=>"logging",:class=>"logged-out"}) do
          with_tag "a", :with=>{ :id=>"signup-link", :href=>"/new/:signup" }, :text=>"Join"
          with_tag "a", :with=>{ :id=>"signin-link", :href=>"/:signin" }, :text=>"Log in"
        end
      end
    end
     context "when the user did not sign in" do
      it do
        login_as 'joe_user'
        expect(@account_link.format(:format=>:html).render_raw).to have_tag("span", :with=>{:id=>"logging",:class=>"logged-in"}) do
          with_tag "a", :with=>{ :id=>"my-card-link", :href=>"/Joe_User" }, :text=>"Joe User"
          with_tag "a", :with=>{ :id=>"invite-a-friend-link", :href=>"/new/:signup" }, :text=>"Invite"
          with_tag "a", :with=>{ :id=>"signout-link", :href=>"/delete/:signin" }, :text=>"Log out"
        end
      end
    end
  end

end