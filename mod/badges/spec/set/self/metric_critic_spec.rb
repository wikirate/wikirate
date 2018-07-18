# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::MetricCritic do
  it_behaves_like "badge card", :metric_critic, :silver, 5
end
