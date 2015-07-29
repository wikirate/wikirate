
describe Card::Set::Type::MetricValue do
  describe "update metric value's value" do
    it "updates metric value' value correctly" do
      @metric = get_a_sample_metric
      @company = get_a_sample_company
      subcard = {
        "+metric"=>{"content"=>@metric.name},
        "+company"=>{"content"=>"[[#{@company.name}]]",:type_id=>Card::PointerID},
        "+value"=>{"content"=>"I'm fine, I'm just not happy.", :type_id=>Card::PhraseID},
        "+year"=>{"content"=>"2015", :type_id=>Card::PointerID},
        "+Link"=>{:content=>"http://www.google.com/?q=everybodylies", "type_id"=>Card::PhraseID}
      }
      metric_value = Card.create! :type_id=>Card::MetricValueID, :subcards=>subcard

      metric_value.update_attributes! :subcards=>{"+value"=>"if nobody hates you, you're doing something wrong."}

      metric_values_value_card = Card["#{metric_value.name}+value"]
      expect(metric_values_value_card.content).to eq("if nobody hates you, you're doing something wrong.")


    end 
  end
end