shared_examples_for 'numeric_value_type' do |value_type|
  before do
    login_as 'joe_user'
    @metric = get_a_sample_metric
    @company = get_a_sample_company
    @metric.update_attributes! subcards: {
                                '+value_type' => "[[#{value_type}]]" }
    @mv_id = Card::MetricValueID
  end
  describe 'add a new value' do
    context 'value not fit the value type' do
      it 'blocks adding a new value' do
        subcard = get_subcards_of_metric_value @metric, @company, nil, nil, nil

        metric_value = Card.create type_id: @mv_id, subcards: subcard
        expect(metric_value.errors).to have_key(:value)
        error_msg = 'Only numeric content is valid for this metric.'
        expect(metric_value.errors[:value]).to include(error_msg)
      end
    end
    context 'value fit the value type' do
      it 'adds a new value' do
        subcard = get_subcards_of_metric_value @metric, @company, '33', nil, nil
        metric_value = Card.create type_id: @mv_id, subcards: subcard
        expect(metric_value.errors).to be_empty
      end
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
    it_behaves_like 'numeric_value_type', 'Number'
  end
  context 'value type is Monetary' do
    it_behaves_like 'numeric_value_type', 'Monetary'
    describe 'render views' do
      it 'shows currency sign' do
        @metric.update_attributes! subcards: { '+value_type' => '[[Monetary]]' }
        subcard = get_subcards_of_metric_value @metric, @company, '33', nil, nil
        metric_value = Card.create type_id: @mv_id, subcards: subcard
        @metric.update_attributes! subcards: { '+currency' => '$' }
        html = metric_value.format.render_timeline_data
        url = "/#{metric_value.cardname.url_key}?layout=modal&"\
              'slot%5Boptional_horizontal_menu%5D=hide&slot%5Bshow%5D=menu'
        expect(html).to have_tag('div', with: { class: 'timeline-row' }) do
          with_tag('div', with: { class: 'timeline-dot' })
          with_tag('div', with: { class: 'td year' }) do
            with_tag('span', with: { class: 'metric-year' }, text: '2015')
          end
          with_tag('div', with: { class: 'td value' }) do
            with_tag('span', with: { class: 'metric-value' }) do
              with_tag('a', with: { href: url }, text: '33')
            end
            with_tag('span', with: { class: 'metric-unit' }, text: '$')
          end
          with_tag('div', with: { class: 'td credit' }) do
            with_tag('a', with: { href: '/Joe_User' }, text: 'Joe User')
          end
        end
      end
    end
  end
  context 'value type is Category' do
    before do
      login_as 'joe_user'
      @metric = get_a_sample_metric
      @company = get_a_sample_company
      @metric.update_attributes! subcards: {
                                  '+value_type' => "[[#{value_type}]]" }
      @mv_id = Card::MetricValueID
    end
  end

  context 'value type is free text' do
    before do
      login_as 'joe_user'
      @metric = get_a_sample_metric
      subcards_args = {
         '+Unit' => { 'content' => 'Imperial military units',
                      'type_id' => Card::PhraseID }
      }
      @metric.update_attributes! subcards: subcards_args
      @company = get_a_sample_company
      subcard = {
        '+metric' => { 'content' => @metric.name },
        '+company' => { 'content' => "[[#{@company.name}]]",
                        :type_id => Card::PointerID },
        '+value' => { 'content' => "I'm fine, I'm just not happy.",
                      :type_id => Card::PhraseID },
        '+year' => { 'content' => '2015', :type_id => Card::PointerID },
        '+source' => { 'subcards' => {
          'new source' => {
            '+Link' => {
              'content' => 'http://www.google.com/?q=everybodylies',
              'type_id' => Card::PhraseID
            }
          }
        }
        }
      }
      @metric_value =
        Card.create! type_id: Card::MetricValueID, subcards: subcard
    end
    describe 'getting related cards' do
      it 'returns correct year' do
        expect(@metric_value.year).to eq('2015')
      end
      it 'returns correct metric name' do
        expect(@metric_value.metric_name).to eq(@metric.name)
      end
      it 'returns correct company name' do
        expect(@metric_value.company_name).to eq(@company.name)
      end
      it 'returns correct company card' do
        expect(@metric_value.company_card.id).to eq(@company.id)
      end
      it 'returns correct metric card' do
        expect(@metric_value.metric_card.id).to eq(@metric.id)
      end
    end
    describe '#autoname' do
      it 'sets a correct autoname' do
        name = "#{@metric.name}+#{@company.name}+2015"
        expect(@metric_value.name).to eq(name)
      end
    end
    context 'creating metric value' do
      it 'based on subcards' do
        url = 'http://www.google.com/?q=everybodylies'
        source =
          Card::Set::Self::Source.find_duplicates(url).first.cardname.left
        source_card = @metric_value.fetch trait: :source
        expect(source_card.item_names).to include(source)

        value_card = Card["#{@metric_value.name}+value"]
        expect(value_card.content).to eq("I'm fine, I'm just not happy.")
      end

      it 'with an existing source' do
        url = 'http://www.google.com/?q=everybodylies'
        source =
          Card::Set::Self::Source.find_duplicates(url).first.cardname.left
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
          '+source' => { 'content' => source }
        }
        mv = Card.create! type_id: Card::MetricValueID, subcards: subcard
        source_card = mv.fetch trait: :source
        expect(source_card.item_names).to include(source)

        value_card = Card["#{mv.name}+value"]
        expect(value_card.content).to eq("I'm fine, I'm just not happy.")
      end

      it 'with an existing url' do
        url = 'http://www.google.com/?q=everybodylies'
        source =
          Card::Set::Self::Source.find_duplicates(url).first.cardname.left
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
          '+source' => {
            'subcards' => {
              'new source' => {
                '+Link' => {
                  content: url,
                  type_id: Card::PhraseID
                }
              }
            }
          }
        }
        mv = Card.create! type_id: Card::MetricValueID, subcards: subcard
        source_card = mv.fetch trait: :source
        expect(source_card.item_names).to include(source)

        value_card = Card["#{mv.name}+value"]
        expect(value_card.content).to eq("I'm fine, I'm just not happy.")
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
      context 'with another source' do
        it "won't create card new source" do
          quote = "if nobody hates you, you're doing something wrong."
          subcards = {
            '+value' => quote,
            '+source' => {
              'subcards' => {
                'new source' => {
                  '+Link' => {
                    'content' => 'http://www.google.com/?q=everybodylies1',
                    'type_id' => Card::PhraseID
                  }
                }
              }
            }
          }
          @metric_value.update_attributes! subcards: subcards
          metric_values_value_card = Card["#{@metric_value.name}+value"]
          expect(metric_values_value_card.content).to eq(quote)
          expect(Card.exists?('new source')).not_to be
          expect(Card.exists?('new source+link')).not_to be
        end
      end
    end
    describe 'views' do
      it 'renders timeline data' do
        url = "/#{@metric_value.cardname.url_key}?layout=modal&"\
              "slot%5Boptional_horizontal_menu%5D=hide&slot%5Bshow%5D=menu"
        html = @metric_value.format.render_timeline_data
        expect(html).to have_tag('div', with: { class: 'timeline-row' }) do
          with_tag('div', with: { class: 'timeline-dot' })
          with_tag('div', with: { class: 'td year' }) do
            with_tag('span', with: { class: 'metric-year' }, text: '2015')
          end
          with_tag('div', with: { class: 'td value' }) do
            with_tag('span', with: { class: 'metric-value' }) do
              with_tag('a', with: { href: url },
                            text: "I'm fine, I'm just not happy.")
            end
            with_tag('span', with: { class: 'metric-unit' },
                             text: /Imperial military units/)
          end
          with_tag('div', with: { class: 'td credit' }) do
            with_tag('a', with: { href: '/Joe_User' }, text: 'Joe User')
          end
        end
      end
      it 'renders modal_details' do
        url = "/#{@metric_value.cardname.url_key}?layout=modal&"\
              "slot%5Boptional_horizontal_menu%5D=hide&slot%5Bshow%5D=menu"
        html = @metric_value.format.render_modal_details
        expect(html).to have_tag('span', with: { class: 'metric-value' }) do
          with_tag('a', with: { href: url },
                        text: "I'm fine, I'm just not happy.")
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
