RSpec.shared_context "report query" do |type, action|
  let(:user_id) { "Joe User".card_id }
  let(:type_card) { Card[type] }
  let(:action) { action }

  def cql variant
    type_card.report_query(action, user_id, variant)
  end

  def count variant
    Card.search(cql(variant).merge(return: :count))
  end

  def names variant
    Card.search(cql(variant).merge(return: :name))
  end
end

RSpec.shared_examples "variant" do |variant, result|
  it "finds #{variant}" do
    if result.is_a?(Integer)
      expect(count(variant)).to eq result
    else
      expect(names(variant).sort).to eq Array(result)
    end
  end
end

def variants var_specs
  var_specs.each do |variant, result|
    include_examples "variant", variant, result
  end
end
