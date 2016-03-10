shared_examples_for 'views' do |value_type, right_card_name|
  before do
    login_as 'joe_user'
    @metric = get_a_sample_metric
    unless value_type.empty?
      @metric.update_attributes! subcards: { 
                                  '+value_type': "[[#{value_type}]]" }
    end
  end

  it 'renders short view' do
    unless value_type.empty?
      html = @metric.format.render_short_view
      expect(html).to have_tag('div', with: { 
                                        class: "RIGHT-#{right_card_name}" })
    end
  end
  it 'renders modal links' do
    html = @metric.format.render_value_type_edit_modal_link
    content = !value_type.empty? ? value_type : 'Update Value Type'
    expect(html).to have_tag('a', text: content)
  end
end

describe Card::Set::Type::Metric do
  context 'type metric not set' do
    it_behaves_like 'views', '', ''
  end
  context 'Numeric type metric' do
    it_behaves_like 'views', 'Number', 'numeric_detail'
  end
  context 'Monetary type metric' do
    it_behaves_like 'views', 'Monetary', 'monetary_detail'
  end
  context 'Category type metric' do
    it_behaves_like 'views', 'Category', 'category_detail'
  end
end
