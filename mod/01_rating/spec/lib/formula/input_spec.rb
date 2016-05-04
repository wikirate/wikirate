describe Formula::Calculator::Input do
  before do
    Card::Auth.as_bot do
      Card::Metric.create name: 'Joe User+researched1',
                          type: :researched,
                          random_source: true do

        Apple_Inc  '2010' => 10, '2011' => 11, '2012' => 12,
                   '2013' => 13, '2014' => 14
        Death_Star '1977' => 77
      end
    end
  end

  subject do
    input_cards = @input.map { |i| Card.fetch i }
    Formula::Calculator::Input.new(input_cards, @year_options) do |val|
      val.to_f
    end
  end
  it 'single input' do
    @input = ['Jedi+deadliness']
    expect { |b| subject.each(year: 1977, company: 'Death Star', &b) }
      .to yield_with_args([100.0], 'death_star', 1977)
  end

  it 'two metrics' do
    @input = %w(Jedi+deadliness Joe_User+researched1)
    expect { |b| subject.each(year: 1977, &b) }
      .to yield_with_args([100.0, 77.0], 'death_star', 1977)
  end

  it 'year references' do
    @input = ['Joe User+researched1']
    @year_options = ['-1..0']
    expect { |b| subject.each(year: 2013, company: 'Apple Inc', &b) }
      .to yield_with_args([[12.0, 13.0]], 'apple_inc', 2013)
  end
end
