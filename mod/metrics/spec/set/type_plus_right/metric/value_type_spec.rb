describe Card::Set::TypePlusRight::Metric::ValueType do
  def type_change_for_value value, new_type, subject
    subcards = create_answer metric, company, value, nil, nil
    Card.create! type_id: Card::MetricValueID, subcards: subcards
    subject.update_attributes content: new_type
  end

  shared_examples_for "changing type to numeric" do |new_type|
    subject { metric.value_type_card }

    let(:metric) { sample_metric }
    let(:company) { sample_company }

    before { login_as "joe_user" }

    context "some values do not fit the numeric type" do
      it "blocks type changing" do
        type_change_for_value "wow", new_type, subject
        key = "Jedi+Sith Lord in Charge+Death Star+2015".to_sym
        msg = "'wow' is not a numeric value."
        expect(subject.errors).to have_key(key)
        expect(subject.errors[key]).to include(msg)
      end
    end

    context "all values fit the numeric type" do
      it "updates the value type successfully" do
        type_change_for_value "65535", new_type, subject
        expect(metric.value_type).to eq(new_type)
        expect(subject.errors).to be_empty
      end
    end

    context 'some values are "unknown"' do
      it "updates the value type successfully" do
        type_change_for_value "unknown", new_type, subject
        expect(metric.value_type).to eq(new_type)
        expect(subject.errors).to be_empty
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
      let(:company) { sample_company }

      before { login_as "joe_user" }
      context "some values are not in the options" do
        it "blocks type changing" do
          subject.update_attributes content:  "Category"
          expect(subject.errors).to have_key(:value)
        end
      end

      context "all values are in the options" do
        before do
          metric.value_options_card.update_attributes!(
            content: %w[5 10 20 40 50 100].to_pointer_content
          )
        end

        it "updates the value type successfully" do
          subject.update_attributes content: "Category"
          expect(subject.errors).to be_empty
          expect(metric.value_type).to eq("Category")
        end

        context 'some values are "unknown"' do
          it "updates the value type successfully" do
            type_change_for_value "unknown", "Category", subject

            expect(metric.value_type).to eq("Category")
            expect(subject.errors).to be_empty
          end
        end
      end
    end
  end
end
