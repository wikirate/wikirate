class SharedData
  module Badges
    SAMPLE_AFFINITY_BADGES =
      [
        "Death Star+Research Engine+company badge",
        "Evil Project+Researcher+project badge",
        "Death Star+Researcher+company badge"
      ].freeze

    def add_badges
      some_badges_for "Joe Camel"
      all_badges_for "Big Brother"
    end

    def some_badges_for user
      create [user, :metric_value, :badges_earned],
             type: "Pointer",
             content: ["Research Fellow",
                       "Research Engine",
                       "Death Star+Research Engine+company badge",
                       "Researcher",
                       "Evil Project+Researcher+project badge",
                       "Death Star+Researcher+company badge",
                       "Answer Enhancer",
                       "Answer Advancer",
                       "Commentator"].to_pointer_content
    end

    def all_badges_for user
      [:metric, :project, :metric_value,
       :source, :wikirate_company].each do |type|
        content =
          Card::Set::Type.const_get("#{type.to_s.camelcase}::BadgeHierarchy")
            .badge_names
        content += SAMPLE_AFFINITY_BADGES if type == :metric_value
        create! name: [user, type, :badges_earned],
                type: "Pointer",
                content: content.to_pointer_content
      end
    end
  end
end

# [:metric, :project, :metric_value,
#  :source, :wikirate_company].each do |type|
#   content =
#     Card::Set::Type.const_get("#{type.to_s.camelcase}::BadgeHierarchy")
#       .badge_names
#   if type == :metric_value
#     content += [
#       "Death Star+Research Engine+company badge",
#       "Evil Project+Researcher+project badge",
#       "Death Star+Researcher+company badge"
#     ]
#   end
#   Card.create! name: ["Philipp Kuehl", type, :badges_earned],
#           type: "Pointer",
#           content: content.to_pointer_content
# end
