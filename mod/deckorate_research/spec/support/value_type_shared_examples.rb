shared_examples_for "create record" do |value_type, valid_content, invalid_content|
  let(:metric) { sample_metric value_type.to_sym }
  let(:company) { sample_company }
  let(:error_msg) do
    if value_type == :category
      "invalid option(s): #{invalid_content}. " \
      "Please <a href='/Jedi+disturbances_in_the_Force+value_options"\
      "?view=edit' target=\"_blank\">add that option</a>"
    else
      "Only numeric content is valid for this metric."
    end
  end

  describe "create a new record" do
    def record_with_value value
      create_record metric: metric.name, company: company.name, value: value
    end

    context "when value doesn't fit the value type" do
      next unless invalid_content

      xit "fails" do
        expect(record_with_value(invalid_content))
          .to be_invalid.because_of("+values" => include(error_msg))
      end
    end

    context "when value fits the value type" do
      it "saves correct value" do
        record = record_with_value valid_content
        expect(Card[record, :value].content).to eq valid_content
      end
    end

    context 'when value is "unknown"' do
      xit "passes the validation" do
        expect(record_with_value("unknown")).to be_valid
      end
    end
  end
end
