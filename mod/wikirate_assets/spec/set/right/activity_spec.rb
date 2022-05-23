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
      is_expected.to have_tag("div.accordion") do
        with_tag "div.accordion-item" do
          with_tag :button, text: /Empty post/
        end
      end
    end
  end
end
