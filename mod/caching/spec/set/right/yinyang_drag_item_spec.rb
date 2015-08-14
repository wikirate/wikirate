describe Card::Set::Right::YinyangDragItem do
  it 'updates cache if new value added' do
    Card.create! :name=>'Jedi+size', :type_id=>Card::MetricID
    Card.create! :name=>'Jedi+size+Death Star+2015', :type_id=>Card::MetricValueID, :content=>'100'
    expect(Card['Death Star+metric+non-votee search'].item_names).to include('Jedi+size')
  end
end