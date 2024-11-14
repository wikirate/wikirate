include_set Abstract::AwardBadges, squad_type: :record

event :award_record_discussion_badges, :finalize, on: :save, changed: :content do
  award_badge_if_earned :discuss
end
