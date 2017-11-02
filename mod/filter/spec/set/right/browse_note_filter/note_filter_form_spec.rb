# -*- encoding : utf-8 -*-

describe Card::Set::Right::BrowseNoteFilter do
  let(:filter_card) { Card.fetch :claim, :browse_note_filter }

  describe "filter_form" do
    subject { filter_card.format(:html).render_filter_form.squish }

    it "has correct form tag" do
      is_expected.to have_tag(
        "form", with: { action: "/#{Card[:claim].name}+browse_note_filter", method: "get" }
      )
    end

    it "has sort formgroup" do
      is_expected.to have_tag(".sort-input-group") do
        with_select "sort" do
          with_option "Most Important", "important", selected: "selected"
          with_option "Most Recent", "recent"
        end
      end
    end

    # NOTE: temporarily(?) removed cited formgroup
    # it "has cited formgroup" do
    #   is_expected.to have_tag("div", with: { class: "editor" }) do
    #     with_tag "select", with: { id: "filter_cited" } do
    #       with_tag "option", text: "All",
    #                          with: { value: "all", selected: "selected" }
    #       with_tag "option", text: "Yes",
    #                          with: { value: "yes" },
    #                          without: { selected: "selected" }
    #       with_tag "option", text: "No",
    #                          with: { value: "no" },
    #                          without: { selected: "selected" }
    #     end
    #   end
    # end

    it "has company formgroup" do
      is_expected.to include(
        filter_card.format(:html).render_wikirate_company_formgroup.squish
      )
    end

    it "has topic formgroup" do
      is_expected.to include(
        filter_card.format(:html).render_wikirate_topic_formgroup.squish
      )
    end
  end
end
