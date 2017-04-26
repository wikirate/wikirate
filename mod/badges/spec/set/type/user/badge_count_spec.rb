require_relative "../../../support/badge_count_shared_examples.rb"

describe Card::Set::Type::User::BadgeCount do
  subject { Card["Big Brother"].badge_count }

  it_behaves_like "badge count", 32, 12, 11, 9 do
    def badge_count level=nil
      Card["Big Brother"].badge_count level
    end
  end

  it_behaves_like "badge count", 15, 6, 5, 4 do
    def badge_count level=nil
      Card["Big Brother+Metric Values+badges earned"].badge_count level
    end
  end
end
