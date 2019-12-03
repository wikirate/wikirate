# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::MetricBookmarker do
  it_behaves_like "badge card", :metric_bookmarker, :bronze, 1
end
