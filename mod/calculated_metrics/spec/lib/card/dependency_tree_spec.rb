RSpec.describe Card::DependencyTree do
  def formula_tree tree
    tree.each_pair do |source, targets|
      allow(source).to receive(:formula_metrics).and_return targets
    end
  end

  it "iterates in correct order" do
    c1, c2, c3, c4 = sample_metrics(4)
    formula_tree c1 => [c2, c3], c2 => [c4], c3 => [], c4 => [c3]

    expect { |probe| described_class.new([c1, c2]).each_metric(&probe) }
      .to yield_successive_args(c1, c2, c4, c3)
  end

  it "detects loop" do
    c1, c2, c3, c4 = sample_metrics(4)
    formula_tree c1 => [c2, c3], c2 => [c4], c3 => [c1], c4 => [c3]

    expect { described_class.new([c1, c2]).each_metric {} }
      .to raise_error /calculation loop/
  end
end
