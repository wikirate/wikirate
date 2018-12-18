RSpec.describe Formula::Ruby::FunctionTranslator do
  example "working" do
    tr = described_class.translate "100*Total[{{M1|company:Related[M2]}}]/{{M3}}+"\
                                   "Zeros[{{M4}}]"
    expect(tr)
      .to eq "100*[{{M1|company:Related[M2]}}].flatten.sum/{{M3}}+"\
             "[{{M4}}].flatten.count(0)"
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
