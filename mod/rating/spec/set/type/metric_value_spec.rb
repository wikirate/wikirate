
describe Card::Set::Type::MetricValue do
  before do
    @metric = get_a_sample_metric
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
end