# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::MetricVoter do
  it_behaves_like "badge card", :metric_voter, :bronze, 1
end
