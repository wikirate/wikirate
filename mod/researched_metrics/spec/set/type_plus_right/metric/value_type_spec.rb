RSpec.describe Card::Set::TypePlusRight::Metric::ValueType, with_user: "Joe Admin" do
  def type_change_for_value value, value_type, metric
    create_answer metric: metric, company: sample_company, content: value
    card = metric.value_type_card
    Card::Auth.as_bot do
      card.update content: value_type
    end
    card
  end

  shared_examples_for "changing type to numeric" do |new_type|
    let(:metric) { Card["Jedi+Weapons"] }
    let(:value_type_card) { metric.value_type_card }

    context "some values do not fit the numeric type" do
      it "blocks type changing" do
        key = "#{metric.name}+#{sample_company.name}+2015".to_sym
        expect(type_change_for_value("wow", new_type, metric))
          .to be_invalid.because_of(key => include("'wow' is not a numeric value."))
      end
    end

    context "all values fit the numeric type" do
      it "updates the value type successfully" do
        expect(type_change_for_value("65535", new_type, metric)).to be_valid
        expect(metric.value_type).to eq(new_type)
      end
    end

    context 'some values are "unknown"' do
      it "updates the value type successfully" do
        expect(type_change_for_value("unknown", new_type, metric)).to be_valid
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

      let(:metric) { sample_metric :number }

      context "some values are not in the options" do
        it "blocks type changing" do
          subject.update content:  "Category"
          is_expected.to be_invalid.because_of value: include("option")
          expect(subject.errors.first[1])
            .to have_tag :a, text: "100"
        end
      end

      context "all values are in the options", with_user: "Joe Admin" do
        before do
          metric.value_options_card.update(
            content: %w[5 8 9 10 20 40 50 100].to_pointer_content
          )
        end

        it "updates the value type successfully" do
          subject.update content: "Category"
          expect(metric.value_type).to eq "Category"
          is_expected.to be_valid
        end

        context 'some values are "unknown"' do
          it "updates the value type successfully" do
            type_change_for_value "unknown", "Category", metric

            is_expected.to be_valid
            expect(metric.value_type).to eq "Category"
          end
        end
      end
    end
  end
end
