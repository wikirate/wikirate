shared_examples_for 'viewable metric' do |metric_name, value_type, detail_label|
  before do
    login_as 'joe_user'
    @metric = Card[metric_name]
  end

  it 'renders short view' do
    html = @metric.format.render_short_view
    expect(html).to have_tag('div', with: { class: "RIGHT-#{detail_label}" })
  end

  it 'renders modal links' do
    html = @metric.format.render_value_type_edit_modal_link
    content = value_type
    expect(html).to have_tag('a', text: content)
  end
end

describe Card::Set::Type::Metric do
  context 'Numeric type metric' do
    it_behaves_like 'viewable metric', 'Jedi+deadliness',
                    'Number', 'numeric_detail'
  end
  # FIXME: need monetary example
  # context 'Money type metric' do
  #   it_behaves_like 'views', 'Money', 'monetary_detail'
  # end
  context 'Category type metric' do
    it_behaves_like 'viewable metric', 'Jedi+disturbances in the Force',
                    'Category', 'category_detail'
  end
end
