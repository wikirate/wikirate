shared_context "with calculator stub" do
  def calculator formula, *inputs
    described_class.new normalized_inputs(inputs), formula: formula
  end

  def calculate formula, *inputs
    calculator(formula, *inputs).result
  end

  def normalized_inputs inputs
    inputs.map { |i| i.is_a?(Hash) ? i : { metric: i, name: "m1" } }
  end
end
