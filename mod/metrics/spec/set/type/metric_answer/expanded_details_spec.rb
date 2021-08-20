RSpec.describe Card::Set::Type::MetricAnswer::ExpandedDetails do
  def fetch_answer *name_parts
    Card.fetch(Card::Name[name_parts])
  end

  def expanded_details answer_name, metric_type
    fetch_answer(answer_name).format.render "expanded_#{metric_type}_details".to_sym
  end

  describe "view: expanded_formula_details" do
    def format_formula string, hash
      hash.each do |k, v|
        hash[k] = %(<a class="metric-value known-card" href="/#{v[1]}">#{v[0]}</a>)
      end
      formatted = format(string, hash)
      /#{Regexp.escape formatted}/
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
          with_tag "a.metric-value", text: "100"
        end
        with_tag "td", text: "1977"
      end

      expect(table).to have_tag "div.formula-with-values", text: "= 1/100" do
        with_tag :a, with: { href: "/Jedi+deadliness+Death_Star+1977" }, text: 100
      end
    end

    example "formula details with unknown values", as_bot: true do
      metric = Card["Joe User+small multi"]
      metric.create_answers true do
        Apple_Inc 2001 => "Unknown"
      end

      answer = fetch_answer("Jedi+know the unknowns", "Apple Inc", "2001")
      expect(answer.format.formula_details)
        .to have_tag "a.metric-value", with: { href: "/Joe_User+RM+Apple_Inc+2001" },
                                       text: "10"
      expect(answer.format.formula_details)
        .to have_tag "a.metric-value",
                     with: { href: "/Joe_User+small_multi+Apple_Inc+2001" },
                     text: "Unknown"
    end

    example "not_researched and unknown options" do
      answer = "Jedi+know_the_unknowns+Apple Inc+2001"
      table = expanded_details answer, :formula
      expect(table).to have_tag "table" do
        with_tag("td") { with_tag "a", text: "RM" }
        with_tag("td") { with_tag "a.metric-value", text: "Unknown" }
        with_tag "td", text: "2001"
        with_tag("td") { with_tag "a", text: "small multi" }
        with_tag("td") { with_tag "a.metric-value", text: "No value" }
        with_tag "td", text: "2001"
      end

      expect(table).to have_tag "div.formula-with-values", text: "= 10 + 20" do
        with_tag :a, with: { href: "/Joe_User+RM+Apple_Inc+2001" }, text: 10
      end
    end

    example "year argument" do
      answer = "Jedi+deadlier+Slate Rock and Gravel Company+2004"
      table = expanded_details answer, :formula
      expect(table).to have_tag "table" do
        with_tag("td") { with_tag "a", text: "deadliness" }
        with_tag("td") { with_tag "a.metric-value", text: "9" }
        with_tag "td", text: "2004"
        with_tag("td") { with_tag "a", text: "deadliness" }
        with_tag("td") { with_tag "span.metric-value", text: "8" }
        with_tag "td", text: "-1"
      end

      expect(table).to have_tag "div.formula-with-values", text: "= 9-8" do
        with_tag :a,
                 with: { href: "/Jedi+deadliness+Slate_Rock_and_Gravel_Company+2004" },
                 text: "9"
        with_tag :a,
                 with: { href: "/Jedi+deadliness+Slate_Rock_and_Gravel_Company+2004" },
                 text: "8"
      end
    end

    example "year range" do
      answer = "Jedi+deadliness average+Slate Rock and Gravel Company+2005"
      table = expanded_details answer, :formula
      expect(table).to have_tag "table" do
        with_tag "td" do
          with_tag "a", text: "deadliness"
        end
        with_tag :td do
          with_tag "span.metric-value", text: "8, 9, 10"
        end
        with_tag :td, text: "-2..0"
      end

      expect(table).to have_tag "div.formula-with-values", text: "= Total[8, 9, 10]/3" do
        with_tag :a, with: { href: "/Jedi+deadliness+Slate_Rock_and_Gravel_Company" },
                     text: "8, 9, 10"
      end
    end
  end

  describe "view: expanded_score_details" do
    subject do
      fetch_answer("Jedi+deadliness+Joe User+Death Star+1977")
        .format.render :expanded_score_details
    end

    specify do
      is_expected.to have_tag "table" do
        with_tag "th", text: "Scored Metric"
        with_tag "th", text: "Value"

        with_tag "td" do
          with_tag "a", text: "deadliness"
        end
        with_tag "td" do
          with_tag "a.metric-value", text: "100"
        end
      end
    end
  end

  describe "view: expanded_wiki_rating_details" do
    subject do
      fetch_answer("Jedi+darkness rating+Death Star+1977")
        .format.render :expanded_wiki_rating_details
    end

    specify do
      is_expected.to have_tag "table" do
        %w[Metric Input Score Weight Points].each do |text|
          with_tag "th", text: text
        end
        with_tag("td") { with_tag "a", text: "deadliness" }
        with_tag("td") { with_tag "a.metric-value", text: "100" }
        with_tag "td", text: "10"
        with_tag "td", text: "x 60%"
        with_tag "td", text: "= 6.0"
        with_tag("td") { with_tag "a", text: "disturbances in the Force" }
        with_tag("td") { with_tag "a.metric-value", text: "yes" }
        with_tag "td", text: "10"
        with_tag "td", text: "x 40%"
        with_tag "td", text: "= 4.0"
      end
    end
  end

  describe "view: expanded_relationship_details" do
    context "when inverse relationship" do
      let :card_subject do
        Card["Commons+Supplier_of+Los_Pollos_Hermanos+2000"]
      end

      specify do
        expect_view(:expanded_relationship_details)
          .to have_tag("table.wikirate-table") do
          with_tag("span.card-title", "SPECTRE")
          with_tag("span.metric-value", /Tier 1 Supplier/)
          without_tag("button.fa-caret-down")
        end
      end
    end
  end

  describe "view: expanded_descendant_details" do
    subject do
      fetch_answer("Joe User+descendant 1+Sony Corporation+2014")
        .format.render :expanded_descendant_details
    end

    def ancestor_row binding, num, rank
      binding.with_tag "tr" do
        with_tag :td, rank.to_s
        with_tag("td") { with_tag "a", text: "researched number #{num}" }
        with_tag("td") { with_tag "a.metric-value", text: num }
      end
    end

    specify do
      is_expected.to have_tag("table") do
        ["Rank", "Ancestor Metric", "Value"].each do |text|
          with_tag "th", text: text
        end
        ancestor_row self, "2", 1
        ancestor_row self, "1", 2
      end
    end
  end

  context "with overridden formula metric" do
    subject do
      Card.fetch("Jedi+friendliness+Slate_Rock_and_Gravel_Company+2003")
          .format.render :expanded_details
    end

    it "shows overridden value" do
      is_expected.to have_tag "div" do
        with_tag :h5, "Overridden answer"
        with_tag "span.metric-value", /0\.13/
      end
    end

    it "links to input value" do
      input_name = "/Jedi+deadliness+Slate_Rock_and_Gravel_Company+2003"
      is_expected.to have_tag "a.metric-value",
                              with: { href: input_name }, text: "8"
    end
  end

  context "with overridden descendant metric" do
    subject do
      Card.fetch("Joe User+descendant hybrid+Death Star+1977")
          .format.render :expanded_details
    end

    it "shows cited source" do
      is_expected.to have_tag "div.cited-sources" do
        with_tag "div.source-title", /Opera/
      end
    end

    it "shows overridden value" do
      is_expected.to have_tag "div.overridden-answer" do
        with_tag "h5", "Overridden answer"
        with_tag "span.metric-value", /5/
      end
    end

    it "shows table of ancestors" do
      is_expected.to have_tag :table do
        with_tag :th, "Rank"
        with_tag :tr do
          with_tag :td, "2"
          with_tag :td, /researched number 1/
          with_tag :td do
            with_tag "a.metric-value", /5/
          end
        end
      end
    end
  end
end
