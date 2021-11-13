RSpec.describe Card::Set::Abstract::Value::Edit do
  describe "editor" do
    def editor metric
      render_view :input, name: "Joe User+#{metric}+Sony_Corporation+2010+value"
    end

    context "with multi-category having not more than 10 options" do
      subject { editor "small multi" }

      it "has check boxes input" do
        is_expected.to have_tag :input,
                                with: { value: "1", checked: "checked", type: "checkbox" }
        is_expected.to have_tag :input, with: { value: "2", checked: "checked" }
        is_expected.to have_tag :input, with: { value: "3" },
                                        without: { checked: "checked" }
      end
    end

    context "with multi-category having more than 40 options" do
      subject { editor "big multi" }

      it "has multi select input" do
        # TODO: move the larger value option set into test data
        Card["Joe User+big multi+:value_options"].content =
          (1..50).map(&:to_s).to_pointer_content
        is_expected.to have_tag :select, with: { multiple: "multiple" } do
          with_tag :option, with: { value: "1", selected: "selected" }
          with_tag :option, with: { value: "2", selected: "selected" }
          with_tag :option, with: { value: "3" },
                            without: { selected: "selected" }
        end
      end
    end

    context "with category having not more than 10 options" do
      subject { editor "small single" }

      it "has radio buttons input" do
        is_expected.to have_tag :input,
                                with: { type: "radio", value: "1", checked: "checked" }
        is_expected.to have_tag :input, with: { type: "radio", value: "2" },
                                        without: { checked: "checked" }
      end
    end

    context "with category having more than 10 options" do
      subject { editor "big single" }

      it "has single select input" do
        is_expected.to have_tag :select, without: { multiple: "multiple" } do
          with_tag :option, with: { value: "4", selected: "selected" }
          with_tag :option, with: { value: "2" },
                            without: { selected: "selected" }
        end
      end
    end
  end
end
