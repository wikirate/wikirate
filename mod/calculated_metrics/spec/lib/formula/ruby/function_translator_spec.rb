require_relative "../../../support/calculator_stub.rb"

RSpec.describe Formula::Ruby do
  include_context "with calculator stub"
  describe "#function_translator" do
    def translate formula
      described_class.new(formula_parser(formula)).send :translate_functions
    end

    example "working" do
      tr = translate "100*Total[{{M1|company:Related[M2]}}]/{{M3}}+"\
                                   "Zeros[{{M4}}]"
      expect(tr)
        .to eq "100*[{{M1|company:Related[M2]}}].flatten.sum/{{M3}}+"\
             "[{{M4}}].flatten.count(0)"
    end

    example "missing ]" do
      expect { translate "10 * Total[{{M1|company:Related[M2]}}" }
        .to raise_error Formula::Ruby::FunctionTranslator::SyntaxError, /at 11/
    end

    example "missing [" do
      expect { translate "Total{{M1|company:Related[M2]}}" }
        .to raise_error Formula::Ruby::FunctionTranslator::SyntaxError, /at 6/
    end
  end
end
