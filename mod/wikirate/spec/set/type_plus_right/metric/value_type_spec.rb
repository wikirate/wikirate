shared_examples_for 'changing type to numeric' do |new_type|
  let(:metric) { get_a_sample_metric }
  let(:company) { get_a_sample_company }
  before do
    login_as 'joe_user'
  end
  context 'some values do not fit the numeric type' do
    it 'blocks type changing' do
      subcards = get_subcards_of_metric_value metric, company, 'wow', nil, nil
      Card.create! type_id: Card::MetricValueID, subcards: subcards
      value_type_card = metric.fetch trait: :value_type
      value_type_card.content = "[[#{new_type}]]"
      value_type_card.save
      key = 'Jedi+Sith Lord in Charge+Death Star+2015'.to_sym
      msg = "'wow' is not a numeric value."
      expect(value_type_card.errors).to have_key(key)
      expect(value_type_card.errors[key]).to include(msg)
    end
  end
  context 'all values fit the numeric type' do
    it 'updates the value type successfully' do
      subcards = get_subcards_of_metric_value metric, company, '65535', nil,
                                              nil
      Card.create! type_id: Card::MetricValueID, subcards: subcards
      metric.update_attributes! subcards: {
        '+value_type' => "[[#{new_type}]]" }
      value_type_card = metric.fetch trait: :value_type
      expect(value_type_card.item_names[0]).to eq(new_type)
    end
  end
  context 'some values are "unknown"' do
    it 'updates the value type successfully' do
      subcards = get_subcards_of_metric_value metric, company, 'unknown', nil,
                                              nil
      Card.create! type_id: Card::MetricValueID, subcards: subcards
      metric.update_attributes! subcards: {
        '+value_type' => "[[#{new_type}]]" }
      value_type_card = metric.fetch trait: :value_type
      expect(value_type_card.item_names[0]).to eq(new_type)
    end
  end
end

describe Card::Set::TypePlusRight::Metric::ValueType do
  describe 'changing type' do
    context 'to Number' do
      it_behaves_like 'changing type to numeric', 'Number'
    end
    context 'to Money' do
      it_behaves_like 'changing type to numeric', 'Money'
    end
    describe 'to Category' do
      let(:metric) { get_a_sample_metric :number }
      let(:company) { get_a_sample_company }
      before do
        login_as 'joe_user'
      end
      context 'some values are not in the options' do
        it 'blocks type changing' do
          value_type_card = metric.fetch trait: :value_type
          value_type_card.content = '[[Category]]'
          value_type_card.save
          expect(value_type_card.errors).to have_key(:value)
        end
      end
      context 'all values are in the options' do
        before do
          options_card = Card.fetch "#{metric.name}+value options", new: {}
          # in seed data
          options_card.content = "[[100]]\n"
          options_card.save!
        end
        it 'updates the value type successfully' do
          metric.update_attributes! subcards: {
            '+value_type' => '[[Category]]' }
          value_type_card = metric.fetch trait: :value_type
          expect(value_type_card.item_names[0]).to eq('Category')
        end
        context 'some values are "unknown"' do
          it 'updates the value type successfully' do
            subcards = get_subcards_of_metric_value metric, company, 'unknown',
                                                    nil, nil
            Card.create! type_id: Card::MetricValueID, subcards: subcards
            metric.update_attributes! subcards: {
              '+value_type' => '[[Category]]' }
            value_type_card = metric.fetch trait: :value_type
            expect(value_type_card.item_names[0]).to eq('Category')
          end
        end
      end
    end
  end
end
