shared_examples_for 'changing type to numeric' do |original_type, new_type|
  before do
    login_as 'joe_user'
    @metric = get_a_sample_metric
    @company = get_a_sample_company
    @metric.update_attributes! subcards: { '+value_type' =>
                                           "[[#{original_type}]]" }
  end
  context 'some values do not fit the numeric type' do
    it 'blocks type changing' do
      subcards = get_subcards_of_metric_value @metric, @company, 'wow', nil, nil
      @metric_value = Card.create! type_id: Card::MetricValueID,
                                   subcards: subcards
      value_type_card = @metric.fetch trait: :value_type
      value_type_card.content = "[[#{new_type}]]"
      value_type_card.save
      expect(value_type_card.errors).to have_key(:invalid_value)
    end
  end
  context 'all values fit the numeric type' do
    it 'updates the value type successfully' do
      subcards = get_subcards_of_metric_value @metric, @company, '65535', nil,
                                              nil
      @metric_value = Card.create! type_id: Card::MetricValueID,
                                   subcards: subcards
      @metric.update_attributes! subcards: {
        '+value_type' => "[[#{new_type}]]" }
      value_type_card = @metric.fetch trait: :value_type
      expect(value_type_card.item_names[0]).to eq(new_type)
    end
  end
end

describe Card::Set::TypePlusRight::Metric::ValueType do
  describe 'changing type' do
    context 'to Number' do
      it_behaves_like 'changing type to numeric', 'Free Text', 'Number'
    end
    context 'to Monetary' do
      it_behaves_like 'changing type to numeric', 'Free Text', 'Monetary'
    end
    describe 'to Category' do
      before do
        login_as 'joe_user'
        @metric = get_a_sample_metric
        @company = get_a_sample_company
        @metric.update_attributes! subcards: { '+value_type' => '[[Number]]' }
        subcards = get_subcards_of_metric_value @metric, @company, '65535',
                                                nil, nil
        @metric_value = Card.create! type_id: Card::MetricValueID,
                                     subcards: subcards
      end
      context 'some values are not in the options' do
        it 'blocks type changing' do
          value_type_card = @metric.fetch trait: :value_type
          value_type_card.content = '[[Category]]'
          value_type_card.save
          expect(value_type_card.errors).to have_key(:invalid_value)
        end
      end
      context 'all values are in the options' do
        it 'updates the value type successfully' do
          options_card = Card.fetch "#{@metric.name}+value options", new: {}
          options_card.content = '[[65535]]'
          options_card.save!
          @metric.update_attributes! subcards: {
            '+value_type' => '[[Category]]' }
          value_type_card = @metric.fetch trait: :value_type
          expect(value_type_card.item_names[0]).to eq('Category')
        end
      end
    end
  end
end
