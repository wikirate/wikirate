RSpec.describe Card::Set::Right::Specification do
  def card_subject
    Card["Deadliest+specification"]
  end

  def create_group_with_specification! specification, group="Soup Group"
    Card.create! name: group,
                 type: :company_group,
                 fields: { specification: JSON(specification) }
    Card["#{group}+specification"]
  end

  describe "validation event" do
    # note: this tests that card event handles constraint error
    it "catches invalid constraints" do
      expect do
        create_group_with_specification!([{ metric_id: "fake metric", year: 2016 }])
      end.to raise_error(/\+specification invalid metric/)
    end
  end

  describe "HTML format" do
    describe "core view" do
      specify do
        expect_view("core").to(have_tag("table.company-group-specification-table") do
          with_tag "tr.specification-constraint-row" do
            with_tag "td" do
              with_tag ".TYPE-metric.thumbnail"
            end
          end
        end)
      end
    end

    describe "input view" do
      specify do
        expect_view("input")
          .to(have_tag(".constraint-list-editor") do
            with_tag ".input-group.constraint-metric" do
              with_tag "input"
            end
            with_tag ".input-group.constraint-year" do
              with_tag "select"
            end
            with_tag ".input-group.constraint-value" do
              with_tag "input"
            end
          end)
      end
    end
  end
end
