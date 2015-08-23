
describe Card::Set::Type::MetricValue do
  before do
    login_as "joe_user"
    @metric = get_a_sample_metric
    @metric.update_attributes! :subcards=>{"+Unit"=>{"content"=>"Imperial military units","type_id"=>Card::PhraseID}}
    @company = get_a_sample_company
    subcard = {
      "+metric"=>{"content"=>@metric.name},
      "+company"=>{"content"=>"[[#{@company.name}]]",:type_id=>Card::PointerID},
      "+value"=>{"content"=>"I'm fine, I'm just not happy.", :type_id=>Card::PhraseID},
      "+year"=>{"content"=>"2015", :type_id=>Card::PointerID},
      "+Link"=>{:content=>"http://www.google.com/?q=everybodylies", "type_id"=>Card::PhraseID}
    }
    @metric_value = Card.create! :type_id=>Card::MetricValueID, :subcards=>subcard
  end
  describe "getting related cards" do

    it "returns correct year" do
      expect(@metric_value.year).to eq("2015")
    end
    it "returns correct metric name" do
      expect(@metric_value.metric_name).to eq(@metric.name)
    end
    it "returns correct company name" do
      expect(@metric_value.company_name).to eq(@company.name)
    end
    it "returns correct company card" do
      expect(@metric_value.company_card.id).to eq(@company.id)
    end
    it "returns correct metric card" do
      expect(@metric_value.metric_card.id).to eq(@metric.id)
    end
  end
  describe "#autoname" do
    it "sets a correct autoname" do
      expect(@metric_value.name).to eq("#{@metric.name}+#{@company.name}+2015")
    end
  end
  context "creating metric value" do
    it "creates correct metric value based on the subcards" do
      source = Card::Set::Self::Source.find_duplicates("http://www.google.com/?q=everybodylies").first.cardname.left
      source_card = @metric_value.fetch :trait=>:source
      expect(source_card.item_names).to include(source)

      value_card = Card["#{@metric_value.name}+value"]
      expect(value_card.content).to eq("I'm fine, I'm just not happy.")
    end
    it "fails while source card cannot be created" do
      subcard = {
        "+metric"=>{"content"=>@metric.name},
        "+company"=>{"content"=>"[[#{@company.name}]]",:type_id=>Card::PointerID},
        "+value"=>{"content"=>"I'm fine, I'm just not happy.", :type_id=>Card::PhraseID},
        "+year"=>{"content"=>"2015", :type_id=>Card::PointerID}
      }
      fail_metric_value = Card.new :type_id=>Card::MetricValueID, :subcards=>subcard
      expect(fail_metric_value).not_to be_valid
      expect(fail_metric_value.errors).to have_key(:source)
    end
  end
  describe "update metric value's value" do
    it "updates metric value' value correctly" do
      @metric_value.update_attributes! :subcards=>{"+value"=>"if nobody hates you, you're doing something wrong."}
      metric_values_value_card = Card["#{@metric_value.name}+value"]
      expect(metric_values_value_card.content).to eq("if nobody hates you, you're doing something wrong.")
    end
  end
  describe "views" do

    it "renders timeline data" do

      html = @metric_value.format.render_timeline_data
      expect(html).to have_tag("div",:with=>{:class=>"timeline-row"}) do
        with_tag("div",:with=>{:class=>"timeline-dot"})
        with_tag("div",:with=>{:class=>"td year"}) do
          with_tag("span",:with=>{:class=>"metric-year"},:text=>"2015")
        end
        with_tag("div",:with=>{:class=>"td value"}) do
          with_tag("span",:with=>{:class=>"metric-value"}) do
            with_tag("a",:with=>{:href=>"/#{@metric_value.cardname.url_key}?layout=modal&slot%5Boptional_horizontal_menu%5D=hide&slot%5Bshow%5D=menu"},:text=>"I'm fine, I'm just not happy.")
          end
          with_tag("span",:with=>{:class=>"metric-unit"},:text=>/Imperial military units/)
        end
        with_tag("div",:with=>{:class=>'td credit'}) do
          with_tag("a",:with=>{:href=>"/Joe_User"},:text=>"Joe User")
        end
      end
    end
    it "renders modal_details" do
      html = @metric_value.format.render_modal_details
      expect(html).to have_tag("span",:with=>{:class=>"metric-value"}) do
        with_tag("a",:with=>{:href=>"/#{@metric_value.cardname.url_key}?layout=modal&slot%5Boptional_horizontal_menu%5D=hide&slot%5Bshow%5D=menu"},:text=>"I'm fine, I'm just not happy.")
      end
    end
    it "renders concise" do
      html = @metric_value.format.render_concise

      expect(html).to have_tag("span",:with=>{:class=>"metric-year"},:text=>/2015 =/)
      expect(html).to have_tag("span",:with=>{:class=>"metric-value"})
      expect(html).to have_tag("span",:with=>{:class=>"metric-unit"},:text=>/Imperial military units/)
    end
  end
end
