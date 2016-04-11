describe Card::Set::TypePlusRight::Metric::AllValues do
  let(:all_values) { @metric.fetch trait: :all_values }
  before do
    @metric = get_a_sample_metric
    @companies = [
      Card['Death Star'],
      Card['Sony Corporation'],
      Card['Amazon.com, Inc.'],
      Card['Apple Inc.'],
                 ]
    @companies.each.with_index do |company, value_idx|
      0.upto(3) do |i|
        @metric.create_value company: company.name,
                             value: (value_idx + 1) * 5 + i,
                             year: 2015 - i,
                             source: 'http://www.google.com/?q=yo'
      end
    end
  end

  describe '#get_params' do
    it 'returns value from params' do
      Card::Env.params["offset"] = "5"
      expect(all_values.get_params("offset", 0)).to eq(5)
    end
    it 'returns default' do
      expect(all_values.get_params("offset", 0)).to eq(0)
    end
  end
  describe "#get_cached_values" do
    it 'returns correct cached metric values' do
      results = all_values.get_cached_values
      value_idx = 1
      @companies.each do |company|
        expect(results.key?(company.name)).to be_truthy
        for i in 0...3
          expected_result = { year: "#{2015-i}", 'value'=>"#{value_idx*5+i}" }
                              'value' => (value_idx * 5 + i).to_s }
          expect(results[company.name]).to include(expected_result)
        end
        value_idx += 1
      end
    end
  end
  describe '#count' do
    it 'returns correct cached count' do
      result = all_values.count {}
      expect(result).to eq(5)
    end
  end
  describe '#num?' do
    context 'Numeric type' do
      it 'returns true' do
        @metric.update_attributes! subcards: { '+value_type' => '[[Number]]' }
        format = @all_values.format
        expect(format.num?).to be true
        @metric.update_attributes! subcards: { '+value_type' => '[[Monetary]]' }
        expect(format.num?).to be true
      end
    end
    context 'Other type' do
      it 'return false' do
        metric = Card.create! type_id: Card::MetricID, name: 'Totoro+Chinchilla'
        metric.update_attributes! subcards: { '+value_type' => '[[Category]]' }
        all_values = metric.fetch trait: :all_values
        format = all_values.format
        expect(format.num?).to be false
        metric.update_attributes! subcards: { '+value_type' => '[[Free Text]]' }
        expect(format.num?).to be false
      end
    end
  end
  describe "#sorted_result" do
    before do
      @cached_result = all_values.cached_values
      @format = all_values.format
    end
    it 'sorts by company name asc' do
      results = @format.sorted_result @cached_result, 'company_name', 'asc'
                                          'asc', false
      expect(results[0][0]).to eq('Amazon.com, Inc.')
      expect(results[1][0]).to eq('Apple Inc.')
      expect(results[2][0]).to eq('Sony Corporation')
    end
    it 'sorts by company name desc' do
      results = @format.sorted_result @cached_result, "company_name", 'desc'
                                          'desc', false
      expect(results[0][0]).to eq('Sony Corporation')
      expect(results[1][0]).to eq('Apple Inc.')
      expect(results[2][0]).to eq('Amazon.com, Inc.')
    end
    it 'sorts by value asc' do
      results = @format.sorted_result @cached_result, 'value', 'asc'
      expect(results[0][0]).to eq("Sony Corporation")
      expect(results[0][1]).to include({'year'=>'2015', 'value'=>'5'})
      expect(results[1][0]).to eq("Amazon.com, Inc.")
      expect(results[1][1]).to include({'year'=>'2015', 'value'=>'10'})
      expect(results[2][0]).to eq("Apple Inc.")
      expect(results[2][1]).to include({'year'=>'2015', 'value'=>'15'})
    end
    it 'sorts by value desc' do
      results = @format.sorted_result @cached_result, 'value', 'desc'
      expect(results[0][0]).to eq("Apple Inc.")
      expect(results[0][1]).to include({'year'=>'2013', 'value'=>'17'})
      expect(results[1][0]).to eq("Amazon.com, Inc.")
      expect(results[1][1]).to include({'year'=>'2013', 'value'=>'12'})
      expect(results[2][0]).to eq("Sony Corporation")
      expect(results[2][1]).to include({'year'=>'2013', 'value'=>'7'})
    end
  end
  describe "view" do
    it 'renders card_list_header' do
      Card::Env.params["offset"] = "0"
      Card::Env.params["limit"] = "20"
      html = all_values.format.render_card_list_header
      url_key = all_values.cardname.url_key
      expect(html).to have_tag('div',
                               with: { class: 'yinyang-row column-header' }) do
        with_tag :div, with: { class: 'company-item value-item' } do
          with_tag :a, with: {
                                class: 'header metric-list-header slotter',
                                href: "/#{url_key}?item=content"\
                                      '&offset=0&limit=20'\
                                      '&sort_order=asc'\
                                      '&sort_by=company_name'
                              }
          with_tag :a, with: {
                                class: 'data metric-list-header slotter',
                                href: "/#{url_key}?item=content"\
                                      '&offset=0&limit=20'\
                                      '&sort_order=asc&sort_by=value'
                              }
        end
      end
    end
  end
end
