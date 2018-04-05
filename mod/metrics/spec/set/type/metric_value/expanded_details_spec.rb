RSpec.describe Card::Set::Type::MetricValue::ValueDetails do
  def expanded_details answer_name, metric_type
    Card.fetch(answer_name).format.render "expanded_#{metric_type}_details".to_sym
  end

  describe "view: expanded_formula_details" do
    def format_formula string, *values
      values = values.map { |v| "<span class='metric-value'>#{v}</span>" }
      format(string, *values)
    end

    specify do
      table = expanded_details "Jedi+friendliness+Death Star+1977", :formula
      expect(table).to have_tag "table" do
        with_tag "th", text: "Metric"
        with_tag "th", text: "Value"
        with_tag "th", text: "Year"

        with_tag "td" do
          with_tag "a", text: "deadliness"
        end
        with_tag "td" do
          with_tag "span.metric-value", text: "100"
        end
        with_tag "td", text: "1977"
      end

      expect(table).to include format_formula("= 1/%s", 100)
    end

    example "year argument" do
      answer = "Jedi+deadlier+Slate Rock and Gravel Company+2004"
      table = expanded_details answer, :formula
      expect(table).to have_tag "table" do
        with_tag "td" do
          with_tag "a", text: "deadliness"
        end
        with_tag "td" do
          with_tag "span.metric-value", text: "9"
        end
        with_tag "td", text: "2004"

        with_tag "td" do
          with_tag "a", text: "deadliness"
        end
        with_tag "td" do
          with_tag "span.metric-value", text: "8"
        end
        with_tag "td", text: "-1"

        with_tag "td" do
          with_tag "a", text: "half year"
        end
        with_tag "td" do
          with_tag "span.metric-value", text: "1002"
        end
        with_tag "td", text: "2004"
      end

      expect(table).to include(format_formula("= %s-%s+%s", 9, 8, 1002))
    end

    example "year range" do
      answer = "Jedi+deadliness average+Slate Rock and Gravel Company+2005"
      table = expanded_details answer, :formula
      expect(table).to have_tag "table" do
        with_tag "td" do
          with_tag "a", text: "deadliness"
        end
        with_tag "td" do
          with_tag "span.metric-value", text: "8, 9, 10"
        end
        with_tag "td", text: "-2..0"
      end

      expect(table).to include(format_formula("= Sum[%s]", "8, 9, 10"))
    end
  end

  describe "view: expanded_score_details" do
    subject do
      Card.fetch("Jedi+deadliness+Joe User+Death Star+1977")
          .format.render :expanded_wikirating_details
    end

    specify do
      is_expected.to have_tag "table" do
        with_tag "th", text: "Original Metric"
        with_tag "th", text: "Value"

        with_tag "td" do
          with_tag "a", text: "deadliness"
        end
        with_tag "td" do
          with_tag "span.metric-value", text: "100"
        end
      end
    end
  end

  describe "view: expanded_wikirating_details" do
    subject do
      Card.fetch("Jedi+darkness rating+Death Star+1977")
          .format.render :expanded_wikirating_details
    end

    specify do
      is_expected.to have_tag "table" do
        with_tag "th", text: "Metric"
        with_tag "th", text: "Raw Value"
        with_tag "th", text: "Score"
        with_tag "th", text: "Weight"
        with_tag "th", text: "Points"

        with_tag "td" do
          with_tag "a", text: "deadliness"
        end
        with_tag "td" do
          with_tag "span.metric-value", text: "100"
        end
        with_tag "td", text: "10.0"
        with_tag "td", text: "x 60%"
        with_tag "td", text: "= 6.0"

        with_tag "td" do
          with_tag "a", text: "disturbances in the Force"
        end
        with_tag "td" do
          with_tag "span.metric-value", text: "yes"
        end
        with_tag "td", text: "10.0"
        with_tag "td", text: "x 40%"
        with_tag "td", text: "= 4.0"
      end
    end
  end
end
