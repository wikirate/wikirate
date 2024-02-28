RSpec.describe Card::DependencyTree do
  def formula_tree tree
    tree.each_pair do |source, targets|
      allow(source).to receive(:formula_metrics).and_return targets
    end
  end

  context "when depender tree" do
    let(:researched_metric) { "Jedi+deadliness".card }
    let(:depender_tree) { described_class.new :depender, researched_metric }

    xit "produces tree" do
      puts depender_tree.tree
    end

    it "iterates in correct order" do
      c1, c2, c3, c4, c5 = sample_metrics(5)
      formula_tree c1 => [c2, c3], c2 => [c3, c4], c3 => [c5], c4 => [], c5 => [c4]

      expect { |probe| described_class.new(:depender, c1).each_metric(&probe) }
        .to yield_successive_args(c2, c3, c5, c4)
    end

    it "detects loop" do
      # c2 depends on c4 and c4 depends on c2
      c1, c2, c3, c4, c5 = sample_metrics(5)
      formula_tree c1 => [c2, c3], c2 => [c3, c4], c3 => [c5], c4 => [c2], c5 => [c4]

      expect { described_class.new(:depender, c1).each_metric {} }
        .to raise_error /calculation loop/
    end
  end
end
