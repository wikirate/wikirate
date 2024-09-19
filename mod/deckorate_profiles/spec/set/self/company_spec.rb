RSpec.describe Card::Set::Self::Company, "company report queries" do
  def answer year, title="big single"
    ["Joe User+#{title}+Sony Corporation+#{year}"]
  end
  describe "created query" do
    include_context "report query", :company, :created
    variants all: "created company"
  end

  describe "updated query" do
    include_context "report query", :company, :updated
    variants all: "updated company"
  end

  describe "discussed query" do
    include_context "report query", :company, :discussed
    variants all: "discussed company"
  end
end
