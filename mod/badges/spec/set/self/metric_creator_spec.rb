# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::MetricCreator do
  it_behaves_like "badge card", :metric_creator, :bronze, 1
end
