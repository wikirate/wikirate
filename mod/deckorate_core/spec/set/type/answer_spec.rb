RSpec.describe Card::Set::Type::Answer do
  describe "answers by value type" do
    def card_subject
      sample_answer value_type
    end

    Deckorate::Samples::METRIC_NAMES.each_key do |value_type|
      context "with #{value_type} answer" do
        let(:value_type) { value_type }

        check_views_for_errors
        check_views_for_errors views: %i[bar page concise]
      end
    end
  end

  describe "answers by metric type" do
    def card_subject
      subject_with_metric_type
    end

    {
      score: "Jedi+disturbances in the Force+Joe User+Death Star+1977",
      wikirating: "Jedi+deadliness+Death_Star+1977",
      formula: "Jedi+friendliness+Death Star+1977",
      relation: "Jedi+more evil+Death Star+1977"
    }.each do |metric_type, answer_name|
      context "with #{metric_type} answer" do
        let(:subject_with_metric_type) { Card.fetch answer_name }

        check_views_for_errors
        check_views_for_errors views: [:page]
      end
    end
  end

  def fetch_answer *name_parts
    Card.fetch Card::Name[name_parts]
  end

  # describe "view: expanded_formula_details" do
  #   def format_formula string, hash
  #     hash.each do |k, v|
  #       hash[k] = %(<a class="metric-value known-card" href="/#{v[1]}">#{v[0]}</a>)
  #     end
  #     formatted = format(string, hash)
  #     /#{Regexp.escape formatted}/
  #   end
  #
  #   specify do
  #     expect_formula_table "Jedi+friendliness+Death Star+1977", "1 / m1" do
  #       with_tag "th", text: "Metric"
  #       with_tag "th", text: "Value"
  #       with_tag "th", text: "Year"
  #
  #       with_tag "td" do
  #         with_tag "a", text: "deadliness"
  #       end
  #       with_tag "td" do
  #         with_tag "a.metric-value", text: "100"
  #       end
  #       with_tag "td", text: "1977"
  #     end
  #   end
  #
  #   example "not_researched and unknown options" do
  #     expect_formula_table "Jedi+know_the_unknowns+Apple Inc+2001", "m1 + m2" do
  #       with_tag("td") { with_tag "a", text: "RM" }
  #       with_tag("td") { with_tag "a.metric-value", text: "Unknown" }
  #       with_tag "td", text: "2001"
  #       with_tag("td") { with_tag "a", text: "small multi" }
  #       with_tag("td") { with_tag "a.metric-value", text: "No value" }
  #       with_tag "td", text: "2001"
  #     end
  #   end
  #
  #   example "year argument" do
  #     expect_formula_table "Jedi+deadlier+Slate Rock and Gravel Company+2004",
  #                          "m1 + m2" do
  #       with_tag("td") { with_tag "a", text: "deadliness" }
  #       with_tag("td") { with_tag "a.metric-value", text: "9" }
  #       with_tag "td", text: "2004"
  #       with_tag("td") { with_tag "a", text: "deadliness" }
  #       with_tag("td") { with_tag "span.metric-value", text: "8" }
  #       with_tag "td", text: "-1"
  #     end
  #   end
  #
  #   example "year range" do
  #     answer = "Jedi+deadliness average+Slate Rock and Gravel Company+2005"
  #     table = expanded_details answer, :formula
  #     expect(table).to have_tag "table" do
  #       with_tag "td" do
  #         with_tag "a", text: "deadliness"
  #       end
  #       with_tag :td do
  #         with_tag "span.metric-value", text: "8, 9, 10"
  #       end
  #       with_tag :td, text: "-2..0"
  #     end
  #
  #     expect(table).to have_tag "div.formula-content", text: "= SUM m1"
  #   end
  # end
  #
  # describe "#expanded_score_details" do
  #   subject do
  #     fetch_answer("Jedi+deadliness+Joe User+Death Star+1977")
  #       .format.expanded_score_details
  #   end
  #
  #   specify do
  #     is_expected.to have_tag "table" do
  #       with_tag "th", text: "Scored Metric"
  #       with_tag "th", text: "Value"
  #
  #       with_tag "td" do
  #         with_tag "a", text: "deadliness"
  #       end
  #       with_tag "td" do
  #         with_tag "a.metric-value", text: "100"
  #       end
  #     end
  #   end
  # end
  #
  # describe "#expanded_rating_details" do
  #   subject do
  #     fetch_answer("Jedi+darkness rating+Death Star+1977")
  #       .format.expanded_rating_details
  #   end
  #
  #   specify do
  #     is_expected.to have_tag "table" do
  #       %w[Metric Input Score Weight Points].each do |text|
  #         with_tag "th", text: text
  #       end
  #       with_tag("td") { with_tag "a", text: "deadliness" }
  #       with_tag("td") { with_tag "a.metric-value", text: "100" }
  #       with_tag "td", text: /10/
  #       with_tag "td", text: "x 60%"
  #       with_tag "td", text: "= 6.0"
  #       with_tag("td") { with_tag "a", text: "disturbances in the Force" }
  #       with_tag("td") { with_tag "a.metric-value", text: "yes" }
  #       with_tag "td", text: /10/
  #       with_tag "td", text: "x 40%"
  #       with_tag "td", text: "= 4.0"
  #     end
  #   end
  # end
  #
  # describe "expanded_descendant_details" do
  #   subject do
  #     fetch_answer("Joe User+descendant 1+Sony Corporation+2014")
  #       .format.expanded_descendant_details
  #   end
  #
  #   def ancestor_row binding, num, rank
  #     binding.with_tag "tr" do
  #       with_tag :td, rank.to_s
  #       with_tag("td") { with_tag "a", text: "researched number #{num}" }
  #       with_tag("td") { with_tag "a.metric-value", text: num }
  #     end
  #   end
  #
  #   specify do
  #     is_expected.to have_tag("table") do
  #       ["Rank", "Ancestor Metric", "Value"].each do |text|
  #         with_tag "th", text: text
  #       end
  #       ancestor_row self, "2", 1
  #       ancestor_row self, "1", 2
  #     end
  #   end
  # end

  context "with overridden formula metric" do
    subject do
      Card.fetch("Jedi+friendliness+Slate_Rock_and_Gravel_Company+2003")
          .format.render :expanded_details
    end

    it "shows overridden value" do
      is_expected.to have_tag "div.overridden-answer.metric-value", /0\.13/
    end

    # it "links to input value" do
    #   url = "/Jedi+deadliness+Slate_Rock_and_Gravel_Company+2003?layout=modal"
    #   is_expected.to have_tag "a.metric-value", with: { href: url }, text: "8"
    # end
  end

  context "with overridden descendant metric" do
    subject do
      Card.fetch("Joe User+descendant hybrid+Death Star+1977")
          .format.render :expanded_details
    end

    it "shows overridden value" do
      is_expected.to have_tag "div.overridden-answer.metric-value", /5/
    end

    # it "shows table of ancestors" do
    #   is_expected.to have_tag :table do
    #     with_tag :th, "Rank"
    #     with_tag :tr do
    #       with_tag :td, "2"
    #       with_tag :td, /researched number 1/
    #       with_tag :td do
    #         with_tag "a.metric-value", /5/
    #       end
    #     end
    #   end
    # end
  end
end
