describe Card::Set::Right::Activity do
  before do
    with_user "joe_user" do
      Card.create! type_id: Card::PostID, name: "Empty post"
    end
  end

  let :post do
    Card["Empty post"]
  end

  describe "core view" do
    subject { render_view :core, name: "joe_user+activity" }

    it "renders view" do
      is_expected.to have_tag("div.activity") do
        with_tag "span", with: { class: "time" }, text: "less than a minute ago"
        with_tag "div", text: /created a new post/ do
          with_tag "a", with: { href: "/#{post.name.url_key}" },
                        text: post.name
        end
      end
    end
  end
end
