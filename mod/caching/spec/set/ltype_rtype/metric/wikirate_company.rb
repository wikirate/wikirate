describe Card::Set::LtypeRtype::Metric::WikirateCompany do
  def subcards_of_metric_value metric, company, content, year=nil, source=nil
    this_year = year || "2015"
    this_source = source || sample_source.name
    this_content = content || "I'm fine, I'm just not happy."
    {
      "+metric" => { "content" => metric.name },
      "+company" => { "content" => "[[#{company.name}]]",
                      :type_id => Card::PointerID },
      "+value" => { "content" => this_content, :type_id => Card::PhraseID },
      "+year" => { "content" => this_year, :type_id => Card::PointerID },
      "+source" => { "content" => "[[#{this_source}]]\n",
                     :type_id => Card::PointerID }
    }
  end

  context "metric values updated" do
    let(:metric) { sample_metric :number }
    let(:company) { sample_company }
    let(:mv_id) { Card::MetricValueID }

    before do
      login_as "joe_admin"
      @metric_value =
        Card.create type_id: mv_id,
                    subcards: subcards_of_metric_value(metric, company, "33", "2015", nil)
      @metric_company = Card.fetch "#{metric.name}+#{company.name}"
    end
    describe "creating a metric value" do
      it "updates latest year" do
        expect(@metric_company.cached_count).to eq(2015)
      end
    end
    describe "deleting a metric value" do
      it "updates latest year to zero" do
        all_mv = Card.search type_id: Card::MetricValueID,
                             left: @metric_company.name
        all_mv.each(&:delete)
        @metric_company.delete
        expect(@metric_company.cached_count).to eq(0)
      end
    end
  end
end
