# -*- encoding : utf-8 -*-

describe Card::Set::Self::AccountLinks do
  before do
    
    @account_link = Card[:account_links]
  end
  describe "raw view" do
    context "when the user signed in" do
      it do
        login_as 'Anonymous' 
        expected_html = %{<span id=\"logging\" class=\"logged-out\"><a class=\"btn btn-highlight\" href=\"/new/:signup\" id=\"signup-link\">Join</a> <a class=\"btn btn-default\" href=\"/:signin\" id=\"signin-link\">Log in</a></span>}
        expect(@account_link.format(:format=>:html).render_raw.squish).to eq(expected_html.squish)
        
      end
    end
     context "when the user did not sign in" do
      it do
        login_as 'joe_user'
        expected_html = %{<span id=\"logging\" class=\"logged-in\"><a class=\"known-card\" href=\"/Joe_User\" id=\"my-card-link\">Joe User</a> <a href=\"/new/:signup\" id=\"invite-a-friend-link\">Invite</a> <a href=\"/delete/:signin\" id=\"signout-link\">Log out</a></span>}
        expect(@account_link.format(:format=>:html).render_raw.squish).to eq(expected_html.squish) 
        
      end
    end
  end

end