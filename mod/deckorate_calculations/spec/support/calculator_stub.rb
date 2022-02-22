shared_context "with calculator stub" do
  def calculator formula, *inputs
    Calculate::Calculator.new normalized_inputs(inputs), formula: formula
  end

  def calculate formula, *inputs
    described_class.new(normalized_inputs(inputs), formula: formula).result
  end

  def normalized_inputs inputs
    inputs.map { |i| i.is_a?(Hash) ? i : { metric: i, name: "m1"}}
  end
end
