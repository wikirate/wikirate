# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::ProjectLauncher do
  it_behaves_like "badge card", :project_launcher, :silver, 1
end
