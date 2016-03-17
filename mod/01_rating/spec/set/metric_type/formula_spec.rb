# -*- encoding : utf-8 -*-

describe Card::Set::MetricType::Formula do
  include_examples 'calculation', :score
  #it_behaves_like 'calculation', :score do
    #end

  describe '#valid_ruby_expression?' do
    subject do
      Card::Auth.as_bot do
        Card.create! name: 'Jedi+evil rating', type_id: Card::MetricID,
                     subcards: {
                       '+*metric type' => "[[#{Card[:wiki_rating].name}]]",
                     }
      end
    end
    it 'allows math operations' do
      expect(subject.valid_ruby_expression? '5 * 4 / 2 - 2.3 + 5').to be_truthy
    end

    it 'allows parens' do
      expect(subject.valid_ruby_expression? '5 * (4 / 2) - 2').to be_truthy
    end

    it 'allows index access to args' do
      expect(subject.valid_ruby_expression? '5 * args[1] + 5').to be_truthy
    end

    it 'denies letters' do
      expect(subject.valid_ruby_expression? '5 * 4*a / 2 - 2 + 5').to be_falsey
    end
  end

  # -*- encoding : utf-8 -*-

  describe Card::Set::MetricType::Researched do
    let(:metric) { Card['Jedi+disturbances in the Force'] }

    describe '#metric_type' do
      subject { metric.metric_type }
      it { is_expected.to eq 'Researched' }
    end
    describe '#metric_type_codename' do
      subject { metric.metric_type_codename }
      it { is_expected.to eq :researched }
    end
    describe '#metric_designer' do
      subject { metric.metric_designer }
      it { is_expected.to eq 'Jedi' }
    end
    describe '#metric_designer_card' do
      subject { metric.metric_designer_card }
      it { is_expected.to eq Card['Jedi'] }
    end
    describe '#metric_title' do
      subject { metric.metric_title }
      it { is_expected.to eq 'disturbances in the Force' }
    end
    describe '#metric_title_card' do
      subject { metric.metric_title_card }
      it { is_expected.to eq Card['disturbances in the Force'] }
    end
    describe '#question_card' do
      subject { metric.question_card.name }
      it { is_expected.to eq 'Jedi+disturbances in the Force+Question'}
    end
    describe '#value_type' do
      subject { metric.value_type }
      it { is_expected.to eq 'Categorical' }
    end
    describe '#value_options' do
      subject { metric.value_options }
      it { is_expected.to eq %w(yes no) }
    end
    describe '#categorical?' do
      subject { metric.categorical? }
      it { is_expected.to be_truthy }
    end
    describe '#researched?' do
      subject { metric.researched? }
      it { is_expected.to be_truthy }
    end
    describe '#scored?' do
      subject { metric.scored? }
      it { is_expected.to be_falsey }
    end
end
