describe Card::Set::TypePlusRight::Metric::AllValues, 'metric value caching' do
  let(:all_values) { Card['Jedi+deadliness'].fetch trait: :all_values }
  let(:create_card) { Card.create name: 'a card' }
  it 'gets updated if value is created in event' do
    $first = true
    expect(all_values.get_cached_values.keys).to eq ['Death_Star']
    Card::Auth.as_bot do
      in_stage :prepare_to_store,
               on: :save,
               trigger: -> { create_card } do
        return unless $first
        $first = false
        Card['Jedi+deadliness'].create_value company: 'Samsung',
                                             year: '2010',
                                             value: '100',
                                             source: get_a_sample_source
      end
    end

    av = Card.fetch('Jedi+deadliness+all values').get_cached_values
    expect(av['Samsung'])
      .to include(value: '100', year: '2010',)
  end
end