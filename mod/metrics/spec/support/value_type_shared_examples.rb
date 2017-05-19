shared_examples_for "value_type" do |value_type, valid_content, invalid_content|
  let(:metric) { sample_metric value_type.to_sym }
  let(:error_msg) do
    if value_type == :category
      "Please <a href='/Jedi+disturbances_in_the_Force+value_options?"\
        "view=edit' target=\"_blank\">add that option</a>"
    else
      "Only numeric content is valid for this metric."
    end
  end

  describe "add a new value" do
    def metric_value content
      create_answer metric: metric, company: sample_company, content: content
    end

    context "value not fit the value type" do
      it "blocks adding a new value" do
        expect(metric_value(invalid_content))
          .to be_invalid.because_of(value: match(error_msg))
      end
    end

    context "value fit the value type" do
      it "adds a new value" do
        expect(metric_value(valid_content)).to be_valid
      end
    end

    context 'value is "unknown"' do
      it "passes the validation" do
        expect(metric_value "unknown").to be_valid
      end
    end
  end
end
