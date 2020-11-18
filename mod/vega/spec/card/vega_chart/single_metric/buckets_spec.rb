RSpec.describe Card::VegaChart::SingleMetric::Buckets do
  let(:bottom) { 582_603 }
  let(:top) { 5_613_573 }

  def buckets lower, upper
    buck = Class.new
    buck.extend described_class
    buck.instance_eval { @buckets = 10 }
    buck.define_singleton_method(:max) { upper }
    buck.define_singleton_method(:min) { lower }
    buck
  end

  def bucket_ranges min, max
    mid = be_between min, max
    [[eq(min), mid, be_falsey]] +
      ([[mid, mid, be_falsey]] * 8) +
      [[mid, be_between(max, max + 200_000).inclusive, be_truthy]]
  end

  describe "#each_bucket" do
    it "creates 10 buckets" do
      expect { |probe| buckets(bottom, top).each_bucket(&probe) }
        .to yield_control.exactly(10).times
    end

    it "calculates correctly" do
      expect { |probe| buckets(bottom, top).each_bucket(&probe) }
        .to yield_successive_args(*bucket_ranges(bottom, top))
    end

    context "with negative values" do
      let(:bottom) { -500_000 }
      let(:top) { 50_600_000 }

      it "calculates correctly" do
        expect { |probe| buckets(bottom, top).each_bucket(&probe) }
          .to yield_successive_args(*bucket_ranges(bottom, top))
      end
    end
  end
end
