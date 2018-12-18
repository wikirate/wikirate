require_relative "../../../support/formula_stub"

RSpec.describe Formula::Ruby do
  include_context "with formula stub"

  describe ".valid_formula?" do
    def valid formula
      expect(::Formula::Ruby.supported_formula?(formula)).to be_truthy
    end

    def invalid formula
      expect(::Formula::Ruby.supported_formula?(formula)).to be_falsey
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
