# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::MetricTonnes do
  it_behaves_like "badge card", :metric_tonnes, :silver, 4
end
