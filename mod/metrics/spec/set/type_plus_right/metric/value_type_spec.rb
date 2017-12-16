RSpec.describe Card::Set::TypePlusRight::Metric::ValueType do
  shared_examples_for "changing type to numeric" do |new_type|
    subject { metric.value_type_card }

    def type_change_for_value value, new_type, subject
      create_answer metric: metric, company: sample_company, content: value
      subject.update_attributes content: new_type
    end

    let(:metric) { Card["Jedi+Weapons"] }
    let(:value_type_card) { metric.value_type_card }

    before { login_as "joe_user" }

    context "some values do not fit the numeric type" do
      it "blocks type changing" do
        type_change_for_value "wow", new_type, subject
        key = "#{metric.name}+#{sample_company.name}+2015".to_sym
        msg = "'wow' is not a numeric value."
        is_expected.to be_invalid.because_of(key => include(msg))
      end
    end

    context "all values fit the numeric type" do
      it "updates the value type successfully" do
        type_change_for_value "65535", new_type, subject
        is_expected.to be_valid
        expect(metric.value_type).to eq(new_type)
      end
    end

    context 'some values are "unknown"' do
      it "updates the value type successfully" do
        type_change_for_value "unknown", new_type, subject
        is_expected.to be_valid
        expect(metric.value_type).to eq(new_type)
      end
    end
  end

  describe "changing type" do
    context "to Number" do
      it_behaves_like "changing type to numeric", "Number"
    end

    context "to Money" do
      it_behaves_like "changing type to numeric", "Money"
    end

    describe "to Category" do
      subject { metric.value_type_card }

      def type_change_for_value value, new_type, subject
        create_answer metric: metric, company: sample_company, content: value
        subject.update_attributes content: new_type
      end

      let(:metric) { sample_metric :number }

      before { login_as "joe_user" }
      context "some values are not in the options" do
        it "blocks type changing" do
          subject.update_attributes content:  "Category"
          is_expected.to be_invalid.because_of value: include("option")
        end
      end

      context "all values are in the options" do
        before do
          metric.value_options_card.update_attributes(
            content: %w[5 8 9 10 20 40 50 100].to_pointer_content
          )
        end

        it "updates the value type successfully" do
          subject.update_attributes content: "Category"
          expect(metric.value_type).to eq "Category"
          is_expected.to be_valid
        end

        context 'some values are "unknown"' do
          it "updates the value type successfully" do
            type_change_for_value "unknown", "Category", subject

            is_expected.to be_valid
            expect(metric.value_type).to eq "Category"
          end
        end
      end
    end
  end
end
