describe Card::Set::Type::User::BadgeCount do
  subject { Card["Big Brother"].badge_count }
  it_behaves_like "badge count", 38, 13, 13, 12 do
    def badge_count level=nil
      Card["Big Brother"].badge_count level
    end
  end
end
