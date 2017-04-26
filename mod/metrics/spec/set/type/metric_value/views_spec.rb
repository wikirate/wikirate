RSpec.describe Card::Set::Type::MetricValue::Views do
  # FIXME: not the right rspec syntax
  # humanized_number doesn't change anything
  describe "#humanized_number" do
    subject do
      @number = Card["Jedi+deadliness+Death Star+1977"].format
                                                       .humanized_number(@number)
    end

    specify do
      @number = "1_000_001"
      expect { subject }.to change { @number }.from("1_000_001").to("1M")
    end
    specify do
      @number = "0.00000123345"
      expect { subject }.to change { @number }.from("0.00000123345").to("0.00000123")
    end
    specify do
      @number = "0.001200"
      expect { subject }.to change { @number }.from("0.001200").to("0.0012")
    end
    specify do
      @number = "123.4567"
      expect { subject }.to change { @number }.from("123.4567").to("123.5")
    end
  end

  describe "view :concise" do
    context "multi category metric" do
      subject do
        render_view :concise,
                    name: "Joe User+big multi+Sony Corporation+2010"
      end

      it "has comma separated list of values" do
        is_expected.to have_tag "span.metric-value" do
          with_text "1, 2"
        end
      end
      it "has correct year" do
        is_expected.to have_tag "span.metric-year" do
          with_text "2010 = "
        end
      end
      it "has no unit" do
        is_expected.to have_tag "span.metric-unit" do
          with_text "  "
        end
      end
    end

    context "single category metric" do
      subject do
        render_view :concise,
                    name: "Joe User+big single+Sony Corporation+2010"
      end

      it "has value" do
        is_expected.to have_tag "span.metric-value" do
          with_text "4"
        end
      end
      it "has correct year" do
        is_expected.to have_tag "span.metric-year" do
          with_text "2010 = "
        end
      end
      it "has no unit" do
        is_expected.to have_tag "span.metric-unit" do
          with_text "  "
        end
      end
    end
  end
end
