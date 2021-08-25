require_relative "../../support/calculator_stub"

RSpec.describe Calculate::Ruby do
  include_context "with calculator stub"

  describe ".valid_formula?" do
    def valid formula
      expect(::Calculate::Ruby).to be_supported_formula(formula)
    end

    def invalid formula
      expect(::Calculate::Ruby).not_to be_supported_formula(formula)
    end

    example "simple symbols" do
      valid "1/{{Jedi+deadliness}}"
    end

    example "several nests and functions" do
      valid "2*Total[{{M1|2000..2010}}]+{{M2}} / Min[{{M3|-1..3}}]"
    end

    example "related companies" do
      valid "2*Total[{{M1|company: Related[M0]}}]+{{M2}}"
    end

    example "unknown method" do
      invalid "2*Total[{{M1|company: Related[M0]}}]+{{M2}} + NotAMethod[M3]"
    end
  end
end
