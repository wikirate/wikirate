shared_examples_for 'all_value_type' do |value_type, valid_cnt, invalid_cnt|
  before do
    login_as 'joe_user'
    @metric = get_a_sample_metric value_type.to_sym
    @company = get_a_sample_company
    @mv_id = Card::MetricValueID
    @error_msg =
      if value_type == :category
        "Please <a href='/Jedi+disturbances_in_the_Force+value_options?"\
        "view=edit' target=\"_blank\">add options</a> before adding metric"\
        ' value.'
      else
        'Only numeric content is valid for this metric.'
      end
  end

  describe 'add a new value' do
    context 'value not fit the value type' do
      it 'blocks adding a new value' do
        subcard =
          get_subcards_of_metric_value @metric, @company, invalid_cnt, nil, nil
        metric_value = Card.create type_id: @mv_id, subcards: subcard
        expect(metric_value.errors).to have_key(:value)
        expect(metric_value.errors[:value]).to include(@error_msg)
      end
    end

    context 'value fit the value type' do
      it 'adds a new value' do
        subcard =
          get_subcards_of_metric_value @metric, @company, valid_cnt, nil, nil
        metric_value = Card.create type_id: @mv_id, subcards: subcard
        expect(metric_value.errors).to be_empty
      end
    end

    context 'value is "unknown"' do
      it 'passes the validation' do
        subcard =
          get_subcards_of_metric_value @metric, @company, 'unknown', nil, nil
        metric_value = Card.create type_id: @mv_id, subcards: subcard
        expect(metric_value.errors).to be_empty
      end
    end
  end
end

shared_examples_for 'numeric type' do |value_type|
  let(:metric) { get_a_sample_metric value_type.to_sym }
  let(:company) { get_a_sample_company }
  let(:mv_id) { Card::MetricValueID }
  context 'unknown value' do
    it 'shows unknown instead of 0 in modal_details' do
      subcard =
        get_subcards_of_metric_value metric, company, 'unknown', nil, nil
      metric_value = Card.create type_id: mv_id, subcards: subcard
      html = metric_value.format.render_modal_details
      expect(html).to have_tag('a', text: 'unknown')
    end
  end
end

describe Card::Set::Type::MetricValue do
  before do
    login_as 'joe_user'
    @metric = get_a_sample_metric
    @company = get_a_sample_company
    @mv_id = Card::MetricValueID
  end

  context 'value type is Number' do
    it_behaves_like 'all_value_type', :number, '33', 'hello', @numeric_error_msg
    it_behaves_like 'numeric type', :number
  end

  context 'value type is Money' do
    it_behaves_like 'all_value_type', :money, '33', 'hello', @numeric_error_msg

    describe 'render views' do
      it 'shows currency sign' do
        metric = get_a_sample_metric :money
        subcard = get_subcards_of_metric_value metric, @company, '33', nil, nil
        metric_value = Card.create type_id: @mv_id, subcards: subcard
        metric.update_attributes! subcards: { '+currency' => '$' }
        html = metric_value.format.render_timeline_data
        # url = "/#{metric_value.cardname.url_key}?layout=modal&"\
        #       'slot%5Boptional_horizontal_menu%5D=hide&slot%5Bshow%5D=menu'
        expect(html).to have_tag('div', with: { class: 'timeline-row' }) do
          with_tag('div', with: { class: 'timeline-dot' })
          with_tag('div', with: { class: 'td year' }) do
            with_tag('span', text: '2015')
          end
          with_tag('div', with: { class: 'td value' }) do
            with_tag('span', with: { class: 'metric-value' }) do
              with_tag('a', text: '33')
            end
            with_tag('span', with: { class: 'metric-unit' }, text: '$')
          end
        end
      end
    end
  end

  context 'value type is category' do
    it_behaves_like 'all_value_type', :category, 'yes', 'hello',
                    @categorical_error_msg
  end

  context 'value type is free text' do
    let(:metric) { get_a_sample_metric }
    let(:company) { get_a_sample_company }
    let(:source) { get_a_sample_source }
    before do
      login_as 'joe_user'
      @metric = get_a_sample_metric
      subcards_args = {
        '+Unit' => { 'content' => 'Imperial military units',
                     'type_id' => Card::PhraseID },
        '+Report Type' => { 'content' => 'Conflict Mineral Report',
                            'type_id' => Card::PointerID }
      }
      @metric.update_attributes! subcards: subcards_args
      subcard = get_subcards_of_metric_value metric, company, 'hoi polloi',
                                             '2015', source.name
      @metric_value =
        Card.create! type_id: Card::MetricValueID, subcards: subcard
    end
    describe 'getting related cards' do
      it 'returns correct year' do
        expect(@metric_value.year).to eq('2015')
      end
      it 'returns correct metric name' do
        expect(@metric_value.metric_name).to eq(metric.name)
      end
      it 'returns correct company name' do
        expect(@metric_value.company_name).to eq(company.name)
      end
      it 'returns correct company card' do
        expect(@metric_value.company_card.id).to eq(company.id)
      end
      it 'returns correct metric card' do
        expect(@metric_value.metric_card.id).to eq(metric.id)
      end
    end
    describe '#autoname' do
      it 'sets a correct autoname' do
        name = "#{metric.name}+#{company.name}+2015"
        expect(@metric_value.name).to eq(name)
      end
    end
    it 'saving correct value' do
      value_card = Card["#{@metric_value.name}+value"]
      expect(value_card.content).to eq('hoi polloi')
    end
    describe '+source' do
      let(:source_card) { @metric_value.fetch trait: :source }
      it 'includes source in +source' do
        expect(source_card.item_names).to include(source.name)
      end

      it "updates source's company and report type" do
        source_company = source.fetch trait: :wikirate_company
        source_report_type = source.fetch trait: :report_type
        expect(source_company.item_cards).to include(company)
        report_name = 'Conflict Mineral Report'
        expect(source_report_type.item_names).to include(report_name)
      end

      it 'fails with a non-existing source' do
        subcard = {
          '+metric' => { 'content' => @metric.name },
          '+company' => {
            'content' => "[[#{@company.name}]]",
            'type_id' => Card::PointerID
          },
          '+value' => {
            'content' => "I'm fine, I'm just not happy.",
            'type_id' => Card::PhraseID
          },
          '+year' => { 'content' => '2014', 'type_id' => Card::PointerID },
          '+source' => { 'content' => 'Page-1' }
        }
        fail_mv = Card.new type_id: Card::MetricValueID, subcards: subcard
        expect(fail_mv).not_to be_valid
        expect(fail_mv.errors).to have_key(:source)
      end

      it 'fails if source card cannot be created' do
        subcard = {
          '+metric' => { 'content' => @metric.name },
          '+company' => { 'content' => "[[#{@company.name}]]",
                          :type_id => Card::PointerID },
          '+value' => { 'content' => "I'm fine, I'm just not happy.",
                        :type_id => Card::PhraseID },
          '+year' => { 'content' => '2015', :type_id => Card::PointerID }
        }
        fail_metric_value = Card.new type_id: Card::MetricValueID,
                                     subcards: subcard
        expect(fail_metric_value).not_to be_valid
        expect(fail_metric_value.errors).to have_key(:source)
      end
    end
    describe "update metric value's value" do
      it "updates metric value's value correctly" do
        quote = "if nobody hates you, you're doing something wrong."
        @metric_value.update_attributes! subcards: {
          '+value' => quote
        }
        metric_values_value_card = Card["#{@metric_value.name}+value"]
        expect(metric_values_value_card.content).to eq(quote)
      end
    end
    describe 'views' do
      it 'renders timeline data' do
        # url = "/#{@metric_value.cardname.url_key}?layout=modal&"\
        #      'slot%5Boptional_horizontal_menu%5D=hide&slot%5Bshow%5D=menu'
        html = @metric_value.format.render_timeline_data
        expect(html).to have_tag('div', with: { class: 'timeline-row' }) do
          with_tag('div', with: { class: 'timeline-dot' })
          with_tag('div', with: { class: 'td year' }) do
            with_tag('span', text: '2015')
          end
          with_tag('div', with: { class: 'td value' }) do
            with_tag('span', with: { class: 'metric-value' }) do
              with_tag('a', text: 'hoi polloi')
            end
            with_tag('span', with: { class: 'metric-unit' },
                             text: /Imperial military units/)
          end
        end
      end
      it 'renders modal_details' do
        url = "/#{@metric_value.cardname.url_key}?layout=modal&"\
              'slot%5Boptional_horizontal_menu%5D=hide&slot%5Bshow%5D=menu'
        html = @metric_value.format.render_modal_details
        expect(html).to have_tag('span', with: { class: 'metric-value' }) do
          with_tag('a', with: { href: url },
                        text: 'hoi polloi')
        end
      end
      it 'renders concise' do
        html = @metric_value.format.render_concise

        expect(html).to have_tag('span', with: { class: 'metric-year' },
                                         text: /2015 =/)
        expect(html).to have_tag('span', with: { class: 'metric-value' })
        expect(html).to have_tag('span', with: { class: 'metric-unit' },
                                         text: /Imperial military units/)
      end
    end
  end
end
