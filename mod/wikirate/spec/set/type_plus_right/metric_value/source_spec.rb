describe Card::Set::TypePlusRight::MetricValue::Source do
  before do
    # create a metric value 
    @metric = get_a_sample_metric
    @company = get_a_sample_company
    @metric_value_card_name = "#{@metric.name}+#{@company.name}+2015" 
  end
  describe "new view" do
    it "shows default source editor while the source is not a real card" do
      metric_value = Card.new  :type_id=>Card::MetricValueID
      html = metric_value.format.render_new :type=>:metric_value
      expect(html).to have_tag("div",:with=>{:class=>"new-source-tab"})
    end
  end
  describe "edit view" do
    it "shows sourcebox source editor while the source is a real card" do
      _subcard = {
        "+metric"=>{"content"=>@metric.name},
        "+company"=>{"content"=>"[[#{@company.name}]]",:type_id=>Card::PointerID},
        "+value"=>{"content"=>"10", :type_id=>Card::PhraseID},
        "+year"=>{"content"=>"2015", :type_id=>Card::PointerID},
        "+source"=>{
          "subcards"=>{
            "new source"=>{
              "+Link"=>{
                "content"=>"http://www.google.com/?q=yo",
                 "type_id"=>Card::PhraseID
              }
            }
          }
        }
      }
      metric_value = Card.create! :name=>@metric_value_card_name, :type_id=>Card::MetricValueID, :subcards=>_subcard
      html = metric_value.format.render_edit
      expect(html).to have_tag("div",:with=>{:class=>"sourcebox"}) do
        with_tag("input",:with=>{:id=>"sourcebox"})
        with_tag("button",:with=>{:name=>"button"})
      end
    end
  end
end