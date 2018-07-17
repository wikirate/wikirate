require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::Researcher do
  it_behaves_like "badge card", :researcher, :bronze, 1
end
