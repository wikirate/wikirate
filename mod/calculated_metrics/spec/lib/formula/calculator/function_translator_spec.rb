RSpec.describe Formula::Calculator::FunctionTranslator do
  def translate str
    ft = described_class.new "aaa" => "bbb" do |replacement, arg|
      "(#{replacement}).(#{arg})"
    end
    ft.translate str
  end

  example "working" do
    expect(translate("aaa[aaa[X]]")).to eq "(bbb).((bbb).(X))"
  end

  example "missing ]" do
    expect { translate "10 * aaa[{{M1|company:Related[M2]}}" }
      .to raise_error Formula::Calculator::FunctionTranslator::SyntaxError, /at 9/
  end

  # example "missing [" do
  #   expect { translate "aaa{{M1|company:Related[M2]}}" }
  #     .to raise_error Formula::Calculator::FunctionTranslator::SyntaxError, /at 4/
  # end

  it "doesn't translate if function is part of a word" do
    expect(translate("aaax+xaaa+xaaax")).to eq "aaax+xaaa+xaaax"
  end
end
