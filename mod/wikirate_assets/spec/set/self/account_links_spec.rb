# -*- encoding : utf-8 -*-

describe Card::Set::Self::AccountLinks do
  before do
    @account_link = Card[:account_links]
  end

  describe "raw view" do
    context "when the user signed in" do
      it do
        login_as "Anonymous"
        rendered_html = @account_link.format(format: :html).render_core

        expect(rendered_html).to(
          have_tag("span", with: { id: "logging", class: "logged-out" }) do
            with_tag "a", with: { class: "signup-link", href: "/new/Sign_up" },
                          text: "Join"
            with_tag "a", with: { class: "signin-link", href: "/*signin" },
                          text: "Log in"
          end
        )
      end
    end

    context "when the user did not sign in" do
      it do
        login_as "joe_user"
        expect(@account_link.format(format: :html).render_core).to(
          have_tag("span", with: { id: "logging", class: "logged-in" }) do
            with_tag "a", text: "Joe User", with: { id: "my-card-link",
                                                    href: "/Joe_User" }
            # with_tag "a", text: "Invite", with: { class: "invite-link",
            #                                       href: "/new/Sign_up" }
            with_tag "a", text: "Log out", with: { class: "signout-link",
                                                   href: "/delete/*signin" }
          end
        )
      end
    end
  end
end
