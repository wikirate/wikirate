describe Card::Set::Abstract::Table do
  subject do
    Card["Samsung"].format_with_set(described_class, :html)
  end

  describe "#wikirate_table" do
    it "renders correctly" do
      table =
        subject.wikirate_table :top_class,
                               [Card["A"], Card["r1"]],
                               [:name, :type],
                               header: %w[header1 header2],
                               table: { class: "table_class" },
                               tr: { class: "tr_class" },
                               td: { class: "td_all",
                                     classes: %w[td_1 td_2] }

      expect(table).to have_tag :table,
                                with: { class: "top_class table_class" } do
        with_tag :tr, with: { class: "tr_class" } do
          with_tag :td, with: { class: "td_all td_1" }, text: "A"
          with_tag :td, with: { class: "td_all td_2" }, text: "Basic"
        end
        with_tag :tr, with: { class: "tr_class" } do
          with_tag :td, with: { class: "td_all td_1" }, text: "r1"
          with_tag :td, with: { class: "td_all td_2" }, text: "Role"
        end
      end
    end
  end

  describe "#wikirate_table_with_details" do
    it "renders details link" do
      table = subject.wikirate_table_with_details :top_class,
                                                  [Card["A"], Card["r1"]],
                                                  [:name, :type],
                                                  tr: { class: "tr" },
                                                  td: { class: "td" },
                                                  details_view: :details

      expect(table).to have_tag :table, with: { class: "top_class" } do
        with_tag :tr, with: { class: "tr tr-details-toggle",
                              "data-details-url" => "/A?view=details" } do
          with_tag :td, with: { class: "td header" }, text: "A"
          with_tag :td, with: { class: "td data" }, text: "Basic"
          with_tag :td, with: { class: "td details" }
        end
        with_tag :tr, with: { class: "tr tr-details-toggle",
                              "data-details-url" => "/r1?view=details" } do
          with_tag :td, with: { class: "td header" }, text: "r1"
          with_tag :td, with: { class: "td data" }, text: "Role"
          with_tag :td, with: { class: "td details" }
        end
      end
    end
  end
end
