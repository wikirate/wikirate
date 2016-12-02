require './test/seed'

describe Card::Set::TypePlusRight::Metric::AllMetricValues do
  let(:company) { @company || Card["Death_Star"] }
  let(:all_metric_values) { company.fetch trait: :all_metric_values }
  let(:latest_answers) do
    ["disturbances in the Force+2001",
     "dinosaurlabor+2000",
     "researched+1977",
     "deadliness+Joe Camel+1977",
     "researched number 1+1977",
     "cost of planets destroyed+1977",
     "deadliness+1977",
     "deadliness+Joe User+1977",
     "darkness rating+1977",
     "disturbances in the Force+Joe User+2001",
     "Victims by Employees+1977",
     "friendliness+1977"]
  end
  let(:latest_metric_keys) do
    ::Set.new(latest_answers.map { |n| n.to_name.left_name.key })
  end
  let(:missing_metrics) do
    Card.search(type_id: Card::MetricID, return: :name).map do |name|
      r_name = name.to_name.parts[1..-1].to_name
      next if latest_metric_keys.include? r_name.key
      r_name.to_s
    end.compact
  end

  def missing_answers year=Time.now.year
    with_year missing_metrics, year
  end

  def with_year list, year=Time.now.year
    Array(list).map { |name| "#{name}+#{year}" }
  end

  # return company+year
  def answers list
    list.map do |c|
      [c.metric_name.parts[1..-1], c.year].flatten.join "+"
    end
  end

  describe "#item_cards" do
    subject do
      answers all_metric_values.item_cards
    end
    it "returns the latest values" do
      puts subject
      is_expected.to eq(latest_answers)
    end

    def filter_by args
      allow(all_metric_values).to receive(:filter_hash) { args }
      answers all_metric_values.item_cards
    end

    context "with single filter condition" do
      context "keyword" do
        it "finds exact match" do
          expect(filter_by(name: "Jedi+disturbances in the Force+Joe User"))
            .to eq ["disturbances in the Force+Joe User+2001"]
        end

        it "finds partial match" do
          expect(filter_by(name: "dead"))
            .to eq with_year(["deadliness+Joe Camel", "deadliness",
                              "deadliness+Joe User"], 1977)
        end

        it "ignores case" do
          expect(filter_by(name: "DeAd"))
            .to eq with_year(["deadliness+Joe Camel", "deadliness",
                              "deadliness+Joe User"], 1977)
        end
      end
      context "year" do
        it "finds exact match" do
          expect(filter_by(year: "2000"))
            .to eq with_year(["disturbances in the Force", "dinosaurlabor",
                              "disturbances in the Force+Joe User"], 2000)
        end
      end
      context "research policy" do
        it "finds exact match" do
          expect(filter_by(research_policy: "Designer Assessed"))
            .to eq %w("dinosaurlabor+2000")
        end
      end
      context "metric type" do
        it "finds formulas" do
          expect(filter_by(metric_type: "Formula"))
            .to eq ["friendliness+1977"]
        end
        it "finds scores" do
          expect(filter_by(metric_type: "Score"))
            .to eq ["deadliness+Joe Camel+1977", "deadliness+Joe User+1977",
                    "disturbances in the Force+Joe User+2001"]
        end
        it "finds wikiratings" do
          expect(filter_by(metric_type: "WikiRating"))
            .to eq ["darkness rating+1977"]
        end
        it "finds researched" do
          expect(filter_by(metric_type: "Researched"))
            .to eq ["disturbances in the Force+2001", "dinosaurlabor+2000",
                    "researched+1977", "researched number 1+1977",
                    "cost of planets destroyed+1977",
                    "deadliness+1977", "Victims by Employees+1977"]
        end
        it "finds combinations" do
          expect(filter_by(metric_type: ["Score", "Formula"]))
            .to eq ["deadliness+Joe Camel+1977", "deadliness+Joe User+1977",
                    "disturbances in the Force+Joe User+2001",
                    "friendliness+1977"]
        end
      end
      context "topic" do
        it "finds exact match" do
          expect(filter_by(topic: "Force"))
            .to eq ["disturbances in the Force+2001"]
        end
      end

      context "vote" do
        it "finds upvoted" do
          expect(filter_by(importance: :upvotes))
            .to eq ["disturbances in the Force+2001"]
        end

        it "finds downvoted" do
          expect(filter_by(importance: :downvotes))
            .to eq ["deadliness+1977"]
        end

        it "finds notvoted" do
          expect(filter_by(importance: :novotes))
            .to eq latest_answers -
                     ["disturbances in the Force+2001", "deadliness+1977"]
        end

        it "finds voted" do
          expect(filter_by(importance: [:upvotes, :downvotes]))
            .to eq ["disturbances in the Force+2001", "deadliness+1977"]
        end

        it "finds upvoted and notvoted" do
          expect(filter_by(importance: [:upvotes, :novotes]))
            .to eq latest_answers - ["deadliness+1977"]
        end
      end

      context "value" do
        it "finds missing values" do
          expect(filter_by(metric_value: :none).sort)
            .to eq missing_answers.sort
        end

        let(:unknown_answers) do
          with_year(
            ["deadliness", "Victims by Employees", "friendliness",
             "deadliness+Joe User", "deadliness+Joe Camel"],
            1977
          )
        end
        it "finds unknown values" do
          @company = Card["Samsung"]
          expect(filter_by(metric_value: :unknown))
            .to eq unknown_answers
        end

        it "finds known values" do
          @company = Card["Samsung"]
          all_known = filter_by(metric_value: :known).all? do |a|
            a.include? "researched number"
          end
          expect(all_known).to be_truthy
        end

        context "filter by update date" do
          before do
            Timecop.freeze(SharedData::HAPPY_BIRTHDAY)
          end
          after do
            Timecop.return
          end
          it "finds today's edits" do
            expect(filter_by(metric_value: :today))
              .to eq ["disturbances in the Force+1990"]
          end

          it "finds this week's edits" do
            expect(filter_by(metric_value: :week))
              .to eq ["disturbances in the Force+1990",
                      "disturbances in the Force+1991"]
          end

          it "finds this months's edits" do
            expect(filter_by(metric_value: :month))
              .to eq ["disturbances in the Force+1990",
                      "disturbances in the Force+1991",
                      "disturbances in the Force+1992"]
          end
        end
      end
      context "invalid filter key" do
        it "doesn't matter" do
          expect(filter_by(not_a_filter: "Death"))
            .to eq latest_answers
        end
      end

      context "project" do
        it "finds exact match" do
          expect(filter_by(project: "Evil Project"))
            .to eq ["disturbances in the Force+2001"]
        end
      end
    end

    context "with multiple filter conditions" do
      context "filter for missing values and ..." do
        it "... year" do
          missing_2001 = missing_answers(2001) +
            with_year(["Victims by Employees", "cost of planets destroyed",
                       "darkness rating", "deadliness", "deadliness+Joe Camel",
                       "deadliness+Joe User", "dinosaurlabor", "friendliness",
                       "researched number 1", "researched"], 2001)
          missing_2001.delete "disturbances in the Force+2001"
          filtered = filter_by(metric_value: :none, year: "2001").sort
          expect(filtered)
            .to eq(missing_2001.sort)
        end
        it "... keyword" do
          expect(filter_by(metric_value: :none, name: "number 2").sort)
            .to eq(with_year(["researched number 2"]))
        end
        it "... project" do
          expect(filter_by(metric_value: :none, project: "Evil Project").sort)
            .to eq(with_year(["researched number 2"]))
        end
        it "... metric_type" do
          expect(filter_by(metric_value: :none,
                           metric_type: "Researched"))
            .to eq with_year(["researched number 3", "researched number 2",
                              "Sith Lord in Charge"])
        end
        it "... policy and year" do
          expect(filter_by(metric_value: :none,
                           research_policy: "Designer Assessed",
                           year: 2001))
            .to eq ["dinosaurlabor+2001"]
        end
      end

      it "policy and importance" do
        expect(filter_by(policy: "Evil Project",
                         importance: :upvotes))
          .to eq(["disturbances in the Force+2001"])
      end

      it "year and industry" do
        Timecop.freeze(SharedData::HAPPY_BIRTHDAY) do
          expect(filter_by(year: "1991",
                           topic: "Force",
                           importance: :upvotes,
                           metric_value: :week
                 ))
            .to eq(with_year("disturbances in the Force", 1991))
        end
      end

      it "all in" do
        Timecop.freeze(SharedData::HAPPY_BIRTHDAY) do
          expect(filter_by(year: "1992",
                           topic: "Force",
                           importance: :upvotes,
                           metric_value: :month,
                           project: "Evil Project",
                           research_policy: "Community Assessed",
                           name: "in the",
                           metric_type: "Researched"))
            .to eq(with_year("disturbances in the Force", 1992))
        end
      end
    end

    context "with sort conditions" do
      def sort_by key, order="asc"
        allow(all_metric_values).to receive(:sort_by) { key }
        allow(all_metric_values).to receive(:sort_order) { order }
        all_metric_values.item_cards.map &:name
      end

      let(:sorted_designer) { ["Fred", "Jedi", "Joe User"] }
      it "sorts by designer name (asc)" do
        sorted = sort_by(:metric_name).map { |n| n.to_name.parts.first }.uniq
        expect(sorted).to eq(sorted_designer)
      end

      it "sorts by designer name (desc)" do
        sorted =
          sort_by(:metric_name, "desc").map { |n| n.to_name.parts.first }.uniq
        expect(sorted).to eq(sorted_designer.reverse)
      end

      it "sorts by title" do
        sorted = sort_by(:title_name).map { |n| n.to_name.parts.second }
        indices =
          ["cost of planets destroyed", "darkness rating", "deadliness",
           "researched number 1", "Victims by Employees"].map do |t|
            sorted.index(t)
          end
        expect(indices).to eq [0, 1, 2, 10, 11]
      end

      it "sorts by recently updated" do
        expect(answers(sort_by(:updated_at)[0..1]))
          .to eq ["dinosaurlabor+2010", "disturbances in the Force+2001"]
      end

      it "sorts by importance" do
        expect(sort_by(:importance)).to eq(
                                          with_year(["Samsung", "Slate_Rock_and_Gravel_Company",
                                                     "Los_Pollos_Hermanos",
                                                     "SPECTRE", "Death_Star"], 1977)
                                        )
      end

    end
  end

  describe "#count" do
    it "returns correct count" do
      expect(all_metric_values.count).to eq(4)
    end
  end

  describe "view" do
    it "renders card_list_header" do
      Card::Env.params["offset"] = "0"
      Card::Env.params["limit"] = "20"
      html = all_metric_values.format.render_card_list_header
      url_key = all_metric_values.cardname.url_key
      expect(html).to have_tag("div",
                               with: { class: "yinyang-row column-header" }) do
        with_tag :div, with: { class: "company-item value-item" } do
          with_tag :a, with: {
            class: "header metric-list-header slotter",
            href: "/#{url_key}?limit=20&offset=0"\
                                      "&sort_by=name"\
                                      "&sort_order=asc&view=content"

          }
          with_tag :a, with: {
            class: "data metric-list-header slotter",
            href: "/#{url_key}?limit=20&offset=0"\
                                      "&sort_by=value&sort_order=asc"\
                                      "&view=content"
          }
        end
      end
    end
  end
end
