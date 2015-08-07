
describe Card::Set::TypePlusRight::MetricValue::Value do
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
    @card = Card.fetch "#{@metric_value.name}+value"
  end
  it "renders timeline row" do
    html = @card.format.render_timeline_row
    expect(html).to have_tag("div",:with=>{:class=>"timeline container"}) do
      with_tag("div",:with=>{:class=>"timeline-body"}) do
        with_tag("div",:with=>{:class=>"pull-left timeline-data"}) do
          with_tag("div",:with=>{:class=>"timeline-row"}) do
            with_tag("div",:with=>{:class=>"timeline-dot"})
            with_tag("div",:with=>{:class=>"td year"}) do
              with_tag("span",:with=>{:class=>"metric-year"},:text=>2015)
            end
            with_tag("div",:with=>{:class=>"td value"}) do
              with_tag("span",:with=>{:class=>"metric-value"}) do
                with_tag("a",:with=>{:href=>"/#{@metric_value.cardname.url_key}?layout=modal&slot%5Boptional_horizontal_menu%5D=hide&slot%5Bshow%5D=menu"},:text=>"I'm fine, I'm just not happy.")
              end
            end
            with_tag("span",:with=>{:class=>"metric-unit"},:text=>"Imperial military units")
          end
        end
      end
    end
  end
end

