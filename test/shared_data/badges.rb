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
      some_badges_for "Joe Camel"
      all_badges_for "Big Brother"
    end

    def some_badges_for user
      create [user, :metric_answer, :badges_earned],
             type: "Pointer",
             content: ["Research Master",
                       "Research Pro",
                       "Death Star+Research Pro+company badge",
                       "Researcher",
                       "Evil Project+Researcher+project badge",
                       "Death Star+Researcher+company badge",
                       "Answer Enhancer",
                       "Answer Advancer",
                       "Commentator"].to_pointer_content
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
