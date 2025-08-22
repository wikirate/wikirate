RSpec.describe Card::Set::Self::Topic do
  %i[created updated bookmarked discussed].each do |type|
    describe "#{type} query" do
      include_context "report query", :topic, type
      variants all: ["Test Topics+#{type} topic"]
    end
  end
end
