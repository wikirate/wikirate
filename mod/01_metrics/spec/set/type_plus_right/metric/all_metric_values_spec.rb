describe Card::Set::TypePlusRight::Metric::AllMetricValues do
  let(:metric) { Card["Jedi+disturbances in the Force"] }
  let(:all_metric_values) { metric.fetch trait: :all_metric_values }
  let(:latest_answers) { %w(Death_Star+2001 Monster_Inc+2000 Slate_Rock_and_Gravel_Company+2005) }

  # return company+year
  def answers list
    list.map do |c|
      c.cardname.parts[2..3].join "+"
    end
  end

  describe "#item_cards" do
    subject do
      answers all_metric_values.item_cards
    end
    it "returns the latest values" do
      is_expected.to eq(latest_answers)
    end
  end

  describe "#filtered_item_cards" do
    def filter_by args
      answers all_metric_values.filtered_item_cards(args)
    end

    context "single filter condition" do
      context "keyword" do
        it "finds exact match" do
          expect(filter_by(name: "Death")).to eq ["Death_Star+2001"]
        end

        it "finds partial match" do
          expect(filter_by(name: "at"))
              .to eq %w(Death_Star+2001 Slate_Rock_and_Gravel_Company+2005)
        end

        it "ignores case" do
          expect(filter_by(name: "death"))
              .to eq ["Death_Star+2001"]
        end
      end
      context "year" do
        it "finds exact match" do
          expect(filter_by(year: "2000"))
              .to eq %w(Death_Star+2000 Monster_Inc+2000)
        end
      end
      context "project" do
        it "finds exact match" do
          expect(filter_by(project: "Star Wars Project"))
              .to eq %w(Death_Star+2001)
        end
      end
      context "industry" do
        it "finds exact match" do
          expect(filter_by(industry: "Technology Hardware"))
              .to eq %w(Death_Star+2001)
        end
      end
      context "value" do
        context "filter by update date" do
          before do
            Timecop.freeze(Time.utc(2100, 2, 5, 12, 0, 0))
          end
          after do
            Timecop.return
          end
          it "finds today's edits" do
            expect(filter_by(metric_value: :today))
                .to eq %w(Death_Star+1990)
          end

          it "finds this week's edits" do
            expect(filter_by(metric_value: :week))
                .to eq %w(Death_Star+1990 Death_Star+1991)
          end

          it "finds this months's edits" do
            # wrong only one company
            expect(filter_by(metric_value: :month))
                .to eq %w(Death_Star+1990 Death_Star+1991 Death_Star+1992)
          end
        end
      end
      context "invalid filter key" do
        it "doesn't matter" do
          expect(filter_by(not_a_filter: "Death"))
              .to eq latest_answers
        end
      end
    end
    subject { answers all_metric_values.item_cards }
    it "returns the latest values" do
      is_expected.to eq(latest_answers)
    end
  end


  describe "format :json" do
    describe "view :core" do
      subject do
        JSON.parse @metric.all_metric_values_card.format(:json).render_core
      end

      it "uses ids as keys" do
        expect(subject.keys.map(&:to_i).sort).to eq @companies.map(&:id).sort
      end

      it "finds all companies with values" do
        create_or_update! "test", type: :pointer
        expect(subject.size).to eq 4
      end
      #
      # it "renders hash with all values for a company" do
      #   values = subject[Card["Death Star"].id.to_s]
      #   expect(values).to be_instance_of Array
      #   expect(values.size).to eq 4
      #   inspect_hashes = values.all? do |h|
      #     h.is_a?(Hash) && h.keys == %w(year value last_update_time)
      #   end
      #   expect(inspect_hashes).to be_truthy
      #   v2014 = values.find { |h| h["year"] == "2014" }
      #   expect(v2014["value"]).to eq "6"
      # end

      it "renders hash with latest values for a company" do
        values = subject[Card["Death Star"].id.to_s]
        expect(values).to be_instance_of Array
        expect(values.size).to eq 1
        inspect_hashes = values.all? do |h|
          h.is_a?(Hash) && h.keys == %w(year value last_update_time)
        end
        expect(inspect_hashes).to be_truthy
        v2014 = values.find { |h| h["year"] == "2014" }
        expect(v2014["value"]).to eq "6"
      end
    end
  end

  describe "#get_params" do
    it "returns value from params" do
      Card::Env.params["offset"] = "5"
      expect(all_metric_values.get_params("offset", 0)).to eq(5)
    end

    it "returns default" do
      expect(all_metric_values.get_params("offset", 0)).to eq(0)
    end
  end

  describe "#count" do
    it "returns correct cached count" do
      result = all_metric_values.count {}
      expect(result).to eq(4)
    end
  end
  describe "#num?" do
    context "Numeric type" do
      it "returns true" do
        @metric.update_attributes! subcards: { "+value_type" => "[[Number]]" }
        format = all_metric_values.format
        expect(format.num?).to be true
        @metric.update_attributes! subcards: { "+value_type" => "[[Money]]" }
        expect(format.num?).to be true
      end
    end
    context "Other type" do
      it "return false" do
        metric = Card.create! type_id: Card::MetricID, name: "Totoro+Chinchilla"
        metric.update_attributes! subcards: { "+value_type" => "[[Category]]" }
        all_metric_values = metric.fetch trait: :all_metric_values
        format = all_metric_values.format
        expect(format.num?).to be false
        metric.update_attributes! subcards: { "+value_type" => "[[Free Text]]" }
        expect(format.num?).to be false
      end
    end
  end
  describe "#sorted_result" do
    before do
      @cached_result = all_metric_values.filtered_values_by_name
      @format = all_metric_values.format
    end
    def sort_params by, order, num=true
      @format.stub(:sort_by) { by }
      @format.stub(:sort_order) { order }
      @format.stub(:num?) { num }
    end
    subject { @format.sorted_result.map { |x| x[0] } }
    it "sorts by company name asc" do
      sort_params "name", "asc", false
      is_expected.to eq(
        ["Amazon.com, Inc.",
         "Apple Inc.",
         "Death Star",
         "Sony Corporation"]
      )
    end
    it "sorts by company name desc" do
      sort_params "name", "desc", false
      is_expected.to eq(
        ["Sony Corporation",
         "Death Star",
         "Apple Inc.",
         "Amazon.com, Inc."]
      )
    end

    it "sorts by value asc" do
      sort_params "value", "asc"
      is_expected.to eq(
        ["Death Star",
         "Sony Corporation",
         "Amazon.com, Inc.",
         "Apple Inc."]
      )
    end

    it "sorts by value desc" do
      sort_params "value", "desc"
      is_expected.to eq(
        ["Apple Inc.",
         "Amazon.com, Inc.",
         "Sony Corporation",
         "Death Star"]
      )
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
