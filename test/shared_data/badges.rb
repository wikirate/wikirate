class SharedData
  # test data for badges
  module Badges
    SAMPLE_AFFINITY_BADGES =
      [
        "Death Star+Research Pro+company badge",
        "Evil Project+Researcher+project badge",
        "Death Star+Researcher+company badge"
      ].freeze

    def add_badges
      all_badges_for "Big Brother"
    end

    def all_badges_for user
      [:metric, :project, :metric_answer,
       :source, :wikirate_company].each do |type|
        content = Card::Set::Abstract::BadgeSquad.for_type(type).badge_names
        content += SAMPLE_AFFINITY_BADGES if type == :metric_answer
        create! name: [user, type, :badges_earned],
                type: "Pointer",
                content: content.to_pointer_content
      end
    end
  end
end
