RSpec.describe Formula::Calculator::FunctionTranslator do

  example "working" do
    ft = described_class.new "aaa" => "bbb" do |replacement, arg|
                     "(#{replacement}).(#{arg})"
                end
    expect(ft.translate "aaa[aaa[X]]").to eq "(bbb).(bbb.(X))"
  end

  example "missing ]" do
    expect { described_class.translate "10 * Total[{{M1|company:Related[M2]}}" }
      .to raise_error Formula::Ruby::FunctionTranslator::SyntaxError, /at 11/
  end

  example "missing [" do
    expect { described_class.translate "Total{{M1|company:Related[M2]}}" }
      .to raise_error Formula::Ruby::FunctionTranslator::SyntaxError, /at 6/
  end
end
