class SharedData
  module Badges
    def add_badges

      create ["Joe Camel", :metric_value, :badges_earned],
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

      [:metric, :project, :metric_value,
       :source, :wikirate_company].each do |type|
        hierarchy =
          Card::Set::Type.const_get("#{type.to_s.camelcase}::BadgeHierarchy")
        create! name: ["Big Brother", type, :badges_earned],
                type: "Pointer",
                content: hierarchy.badge_names.to_pointer_content
      end
      create ["Big Brother", :metric_value, :badges_earned],
             type: "Pointer",
             content: [
               "Death Star+Research Engine+company badge",
               "Evil Project+Researcher+project badge",
               "Death Star+Researcher+company badge"
             ].to_pointer_content
    end
  end
end
