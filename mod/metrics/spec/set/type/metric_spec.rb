shared_examples_for "viewable metric" do |metric_name, value_type, detail_label|
  before do
    login_as "joe_user"
    @metric = Card[metric_name]
  end

  it "renders short view" do
    html = @metric.format.render_short_view
    expect(html).to have_tag("div", with: { class: "RIGHT-#{detail_label}" })
  end

  it "renders modal links" do
    html = @metric.format.render_value_type_edit_modal_link
    expect(html).to have_tag("a", text: value_type)
  end
end

RSpec.describe Card::Set::Type::Metric do
  context "Numeric type metric" do
    it_behaves_like "viewable metric", "Jedi+deadliness",
                    "Number", "numeric_detail"
  end
  # FIXME: need monetary example
  # context 'Money type metric' do
  #   it_behaves_like 'views', 'Money', 'monetary_detail'
  # end
  context "Category type metric" do
    it_behaves_like "viewable metric", "Jedi+disturbances in the Force",
                    "Category", "category_detail"
  end

  describe "#numeric?" do
    let(:metric) { sample_metric }
    subject { metric.numeric? }

    it "returns true for number" do
      metric.value_type_card.update_attributes! content: "Number"
      is_expected.to be true
    end

    it "returns true for money" do
      metric.value_type_card.update_attributes! content: "Money"
      is_expected.to be true
    end

    it "returns false for category" do
      metric.value_type_card.update_attributes! content: "Category"
      is_expected.to be false
    end

    it "returns false for free text" do
      metric.value_type_card.update_attributes! content: "Free Text"
      is_expected.to be false
    end
  end
end
