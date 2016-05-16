describe Card::Set::Type::MetricValueImportFile do
  let(:discussion) { '50 Nerds of Grey' }

  def fill_env_params with_comment=false
    Card::Env.params[:metric_values] = []
    (0..2).each do |i|
      hash = {
        metric: @metric.name, company: @companies[i], year: '2015',
        value: i.to_s, source: 'http://example.com', row: i + 1
      }
      hash[:comment] = discussion if with_comment
      Card::Env.params[:metric_values].push(hash.to_json)
    end
  end
  before do
    login_as 'joe_user'
    test_csv = File.open "#{Rails.root}/mod/wikirate/spec/set/" \
                         'type/import_test.csv'
    @mv_import_file = Card.create! name: 'does it matter?',
                                   metric_value_import_file: test_csv,
                                   type_id: Card::MetricValueImportFileID
    Card::Env.params['is_metric_import_update'] = 'true'
    @metric = get_a_sample_metric
    metric_name = @metric.name
    @companies = ['Amazon.com, Inc.', 'Apple Inc.', 'Sony Corporation']
    @amazon = "#{metric_name}+Amazon.com, Inc.+2015"
    @apple = "#{metric_name}+Apple Inc.+2015"
    @sony = "#{metric_name}+Sony Corporation+2015"
    fill_env_params true
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
    it 'adds the comment' do
      @mv_import_file.update_attributes! subcards: {}
      amazon_metric_discussion_card = Card["#{@amazon}+discussion"]
      apple_metric_discussion_card = Card["#{@apple}+discussion"]
      expect(amazon_metric_discussion_card.content).to include(discussion)
      expect(apple_metric_discussion_card.content).to include(discussion)
    end
    it 'handles import without comment' do
      fill_env_params false
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
          '1' => 'Apple Inc.',
          '2' => 'Sony Corporation',
          '3' => 'Amazon.com, Inc.'
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
