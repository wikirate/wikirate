describe Card::Set::Type::MetricValueImportFile do
  before do
    login_as 'joe_user'
    test_csv = File.open "#{Rails.root}/mod/wikirate/spec/set/" \
                         'type/import_test.csv'
    @mv_import_file = Card.create! name: 'does it matter?',
                                   metric_value_import_file: test_csv,
                                   type_id: Card::MetricValueImportFileID
    Card::Env.params['is_metric_import_update'] = 'true'
    @metric = get_a_sample_metric
    @companies = ['Amazon.com, Inc.', 'Apple Inc.', 'Sony Corporation']
    @amazon = 'Jedi+disturbances in the Force+Amazon.com, Inc.+2015'
    @apple = 'Jedi+disturbances in the Force+Apple Inc.+2015'
    @sony = 'Jedi+disturbances in the Force+Sony Corporation+2015'
    Card::Env.params[:metric_values] = []
    for i in 0..2
      hash = {
        metric: @metric.name,
        company: @companies[i],
        year: '2015',
        value: i.to_s,
        source: 'http://example.com'
      }
      Card::Env.params[:metric_values].push(hash.to_json)
    end
  end
  describe 'import metric values' do
    it 'adds metric values' do
      @mv_import_file.update_attributes! subcards: {}
      
      expect(Card.exists?(@amazon)).to be true
      expect(Card.exists?(@apple)).to be true
      amazon_2015_metric_value_card = Card["#{@amazon}+value"]
      apple_2015_metric_value_card = Card["#{@apple}+value"]
      expect(amazon_2015_metric_value_card.content).to eq('0')
      expect(apple_2015_metric_value_card.content).to eq('1')
    end
    context 'company correction name is filled' do
      before do
        Card::Env.params[:corrected_company_name] = {
          @amazon => 'Apple Inc.',
          @apple => 'Sony Corporation',
          @sony => 'Amazon.com, Inc.'
        }
        @mv_import_file.update_attributes! subcards: {}
      end
      it 'uses the input company name' do
        
        expect(Card.exists?(@amazon)).to be true
        expect(Card.exists?(@apple)).to be true
        expect(Card.exists?(@sony)).to be true

        amazon_2015_metric_value_card = Card["#{@amazon}+value"]
        apple_2015_metric_value_card = Card["#{@apple}+value"]
        sony_2015_metric_value_card = Card["#{@sony}+value"]
        expect(amazon_2015_metric_value_card.content).to eq('2')
        expect(apple_2015_metric_value_card.content).to eq('0')
        expect(sony_2015_metric_value_card.content).to eq('1')
      end
      it "updates companies's aliases" do
        amazon_aliases = Card['Amazon.com, Inc+aliases']
        apple_aliases = Card['Apple Inc+aliases']
        sony_aliases = Card['Sony Corporation+aliases']
        expect(amazon_aliases.item_names).to include('Sony Corporation')
        expect(apple_aliases.item_names).to include('Amazon.com, Inc.')
        expect(sony_aliases.item_names).to include('Apple Inc.')
      end
    end
  end
end
