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
end
