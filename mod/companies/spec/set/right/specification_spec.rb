
RSpec.describe Card::Set::Right::Specification do
  def card_subject
    Card["Deadliest+specification"]
  end

  def create_group_with_specification! specification, group="Soup Group"
    Card.create! name: group, type_code: :company_group,
                 "+specification" => specification
    Card["#{group}+specification"]
  end

  def constraint_class
    described_class.const_get "Constraint"
  end

  describe "Constraint class" do
    it "validates metrics" do
      expect { constraint_class.new("[[not a metric]]", 2016).validate! }
        .to raise_error(/invalid metric/)
    end

    it "validates years" do
      expect { constraint_class.new("[[Fred+dinosaurlabor]]", 20_166).validate! }
        .to raise_error(/invalid year/)
    end

    describe "#to_s" do
      specify do
        expect(constraint_class.new("FRED+dinosaurlabor?", 2016, from: 20).to_s)
          .to eq("[[Fred+dinosaurlabor]],2016,\"{\"\"from\"\":20}\",")
      end
    end
  end

  describe "validation event" do
    # note: this tests that card event handles constraint error
    it "catches invalid constraints" do
      expect { create_group_with_specification! "fake metric,2016" }
        .to raise_error(/Invalid specifications: invalid metric/)
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
