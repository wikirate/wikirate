describe Card::Set::Right::Activity do
  before do
    with_user "joe_user" do
      @source_page = create_source "https://decko.org"
      # the below "create" will make a act without card_id due to the abort :success
      create_source "https://decko.org"
    end
  end

  describe "core view" do
    subject { render_view :core, name: "joe_user+activity" }

    it "renders view" do
      is_expected.to have_tag("div.activity") do
        with_tag "span", with: { class: "time" }, text: "less than a minute ago"
        with_tag "div", text: /created a new source/ do
          with_tag "a", with: { href: "/#{@source_page.name.url_key}" },
                        text: @source_page.name
        end
      end
    end
  end
end
