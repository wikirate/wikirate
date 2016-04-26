describe RubyFormula do
  let(:formula) do
    formula = double(Card)
    allow(formula).to receive(:content)
                        .and_return 'Sum[{{mymetric|year:-2..0}}]'
    allow(formula).to receive(:input_metric_keys).and_return(['mymetric'])
    allow(formula).to receive(:input_values)
      .and_return(
        'samsung' => { 'mymetric' => {
        2010 => 10, 2011 => 11, 2012 => 12, 2013 => 13
        } }
      )
    allow(formula).to receive(:normalize_value) do |v|
      v
    end
    formula
  end
  it 'handles sum' do
    rf = RubyFormula.new(formula)
    result = rf.evaluate
    expect(result[2011]).to eq({})
    expect(result[2012]['samsung']).to eq 33.0
    expect(result[2013]['samsung']).to eq 36.0
  end
end