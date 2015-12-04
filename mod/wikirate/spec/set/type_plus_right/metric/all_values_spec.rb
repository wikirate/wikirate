describe Card::Set::TypePlusRight::Metric::AllValues do
  before do
    @metric = get_a_sample_metric
    
    @all_values = @metric.fetch trait: :all_values
    @companies = [
                    Card["Death Star"],
                    Card["Sony Corporation"],
                    Card["Amazon.com, Inc."],
                    Card["Apple Inc."],
                    Card["Samsung"]
                 ]
    value_idx = 1
    @companies.each do |company|
      for i in 0...3
        _subcard = {
          "+metric"=>{content: @metric.name},
          "+company"=>{content: "[[#{company.name}]]",type_id: Card::PointerID},
          "+value"=>{content: "#{value_idx*5+i}", type_id: Card::PhraseID},
          "+year"=>{content: "#{2015-i}", type_id: Card::PointerID},
          "+source"=>{
            "subcards"=>{
              "new source"=>{
                "+Link"=>{
                  content: "http://www.google.com/?q=yo",
                  type_id: Card::PhraseID
                }
              }
            }
          }
        }
        metric_value = Card.create! type_id: Card::MetricValueID,
                                    subcards: _subcard      
      end
      value_idx += 1
    end
  end
  describe "#get_params" do
    it 'returns value from params' do
      Card::Env.params["offset"] = "5"
      expect(@all_values.get_params("offset", 0)).to eq(5)
    end
    it 'returns default' do
      expect(@all_values.get_params("offset", 0)).to eq(0)
    end
  end
  describe "#get_cached_result" do
    it 'returns correct cached metric values' do
      results = @all_values.get_cached_result
      value_idx = 1
      @companies.each do |company|
        expect(results.has_key?(company.name)).to be_truthy
        for i in 0...3
          expected_result = { 'year'=>"#{2015-i}", 'value'=>"#{value_idx*5+i}" }
          expect(results[company.name]).to include(expected_result)
        end
        value_idx += 1
      end
    end
  end
  describe "#count" do
    it 'returns correct cached count' do
      result = @all_values.count {}
      expect(result).to eq(5)
    end
  end
  describe "#get_sorted_result" do
    before do
      @cached_result = @all_values.get_cached_result
      @format = @all_values.format
    end
    it 'sorts by company name asc' do
      results = @format.get_sorted_result @cached_result, 'company_name', 'asc'
      expect(results[0][0]).to eq('Amazon.com, Inc.')
      expect(results[1][0]).to eq('Apple Inc.')
      expect(results[2][0]).to eq('Death Star')
      expect(results[3][0]).to eq('Samsung')
      expect(results[4][0]).to eq('Sony Corporation')
    end
    it 'sorts by company name desc' do
      results = @format.get_sorted_result @cached_result, "company_name", 'desc'
      expect(results[0][0]).to eq('Sony Corporation')
      expect(results[1][0]).to eq('Samsung')
      expect(results[2][0]).to eq('Death Star')
      expect(results[3][0]).to eq('Apple Inc.')
      expect(results[4][0]).to eq('Amazon.com, Inc.')
    end
    it 'sorts by value asc' do
      results = @format.get_sorted_result @cached_result, 'value', 'asc'
      expect(results[0][0]).to eq("Death Star")
      expect(results[0][1]).to include({'year'=>'2015', 'value'=>'5'})
      expect(results[1][0]).to eq("Sony Corporation")
      expect(results[1][1]).to include({'year'=>'2015', 'value'=>'10'})
      expect(results[2][0]).to eq("Amazon.com, Inc.")
      expect(results[2][1]).to include({'year'=>'2015', 'value'=>'15'})
      expect(results[3][0]).to eq("Apple Inc.")
      expect(results[3][1]).to include({'year'=>'2015', 'value'=>'20'})
      expect(results[4][0]).to eq("Samsung")
      expect(results[4][1]).to include({'year'=>'2015', 'value'=>'25'})
    end
    it 'sorts by value desc' do
      results = @format.get_sorted_result @cached_result, 'value', 'desc'
      expect(results[0][0]).to eq("Samsung")
      expect(results[0][1]).to include({'year'=>'2013', 'value'=>'27'})
      expect(results[1][0]).to eq("Apple Inc.")
      expect(results[1][1]).to include({'year'=>'2013', 'value'=>'22'})
      expect(results[2][0]).to eq("Amazon.com, Inc.")
      expect(results[2][1]).to include({'year'=>'2013', 'value'=>'17'})
      expect(results[3][0]).to eq("Sony Corporation")
      expect(results[3][1]).to include({'year'=>'2013', 'value'=>'12'})
      expect(results[4][0]).to eq("Death Star")
      expect(results[4][1]).to include({'year'=>'2013', 'value'=>'7'})
    end
  end
  describe "view" do
    it 'renders card_list_header' do
      Card::Env.params["offset"] = "0"
      Card::Env.params["limit"] = "20"
      html = @all_values.format.render_card_list_header
      url_key = @all_values.cardname.url_key
      expect(html).to have_tag('div', 
                                with: { class: 'yinyang-row column-header'}) do
        with_tag :div, with: { class: 'company-item value-item' } do
          with_tag :a, with: { 
                                class: 'header metric-list-header slotter',
                                href: "/#{url_key}?item=content"\
                                      "&offset=0&limit=20"\
                                      "&sort_order=asc"\
                                      "&sort_by=company_name"
                              } 
          with_tag :a, with: { 
                                class: 'data metric-list-header slotter',
                                href: "/#{url_key}?item=content"\
                                      "&offset=0&limit=20"\
                                      "&sort_order=asc&sort_by=value"
                              } 
        end

      end
    end    
  end
end