RSpec.describe Formula::Calculator::InputValues do
  def input_values formula
    f_card = Card["Jedi+friendliness+formula"]
    f_card.content = formula
    described_class.new(f_card)
  end

  let(:death_star) { Card.fetch_id "Death Star" }

  def input_item iv, i
    Formula::Calculator::InputItem::MetricInput.new iv, i
  end

  example "simple metric" do
    iv = input_values("2*{{Jedi+Victims by Employees}}")
    iv.send(:search_values)
    ii = input_item(iv, 0)
    expect(ii.value_for death_star, nil)
      .to eq(1977 => "0.31")
  end

  example "metric with year option" do
    iv = input_values("2*{{Jedi+Victims by Employees|year:1977}}")
    iv.send(:search_values)
    ii = input_item(iv, 0)
    expect(ii.value_for death_star, nil)
      .to eq(1977 => "0.31")
  end

  example "metric with company options" do
    iv = input_values("{{Jedi+deadliness|company:Related[Jedi+more evil=yes]}}")
    iv.send(:search_values)
    ii = input_item(iv, 0)
    expect(ii.value_for death_star, nil)
      .to eq(1977 => %w[50 40])
  end
end
