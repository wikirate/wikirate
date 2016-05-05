# encoding: UTF-8

describe Card::Set::TypePlusRight::Metric::Formula do
  describe '#ruby_formula?' do
    subject do
      Card['Jedi+friendliness+formula']
    end
    it 'allows math operations' do
      subject.content = '5 * 4 / 2 - 2.3 + 5'
      expect(subject.ruby_formula?).to be_truthy
    end

    it 'allows parens' do
      subject.content = '5 * (4 / 2) - 2'
      expect(subject.ruby_formula?).to be_truthy
    end

    it 'allows nests' do
      subject.content = '5 * {{metric}} + 5'
      expect(subject.ruby_formula? ).to be_truthy
    end

    it 'denies letters' do
      subject.content ='5 * 4*a / 2'
      expect(subject.ruby_formula?).to be_falsey
    end
  end
  describe '#translate_formula' do
    subject do
      Card['jedi+disturbance_in_the_force+joe_user+formula']
    end
    context 'invalid values' do
      it 'blocks empty values' do
        subject.content = '{"yes":"10","no":""}'
        subject.save
        expect(subject.errors).to have_key(:invalid_value)
        err_msg = "Option:no's value is empty"
        expect(subject.errors[:invalid_value]).to include(err_msg)
      end
      it 'blocks non numeric values' do
        subject.content = '{"yes":"10","no":"yo"}'
        subject.save
        expect(subject.errors).to have_key(:invalid_value)
        err_msg = "Option:no's value is not a number"
        expect(subject.errors[:invalid_value]).to include(err_msg)
      end
      it 'blocks values > 10 and < 0' do
        subject.content = '{"yes":"10","no":"11"}'
        subject.save
        expect(subject.errors).to have_key(:invalid_value)
        err_msg = "Option:no's value is smaller than 0 or bigger than 10"
        expect(subject.errors[:invalid_value]).to include(err_msg)

        subject.content = '{"yes":"10","no":"-1"}'
        subject.save
        expect(subject.errors).to have_key(:invalid_value)
        err_msg = "Option:no's value is smaller than 0 or bigger than 10"
        expect(subject.errors[:invalid_value]).to include(err_msg)
      end
    end
  end
end
